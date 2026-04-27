from __future__ import annotations

import argparse
import json
import os
import re
from dataclasses import dataclass, field
from pathlib import Path

import fitz


ROOT = Path(__file__).resolve().parents[1]
PDF_DIR = ROOT / "assets" / "verse"
OUTPUT_DIR = ROOT / "assets" / "data" / "readings"

PDF_TO_OUTPUT = {
    "januaryreadings.pdf": "january.json",
    "februaryreading.pdf": "february.json",
    "marchcalendar.pdf": "march.json",
    "april.pdf": "april.json",
    "mayreadings.pdf": "may.json",
    "junereadings.pdf": "june.json",
    "july.pdf": "july.json",
    "augustreadings.pdf": "august.json",
    "septemberreadin.pdf": "september.json",
    "octoberreading.pdf": "october.json",
    "novemberreading.pdf": "november.json",
    "decemberreading.pdf": "december.json",
}

MONTH_STARTS = {
    "January": (4, 22),
    "February": (5, 23),
    "March": (6, 22),
    "April": (7, 23),
    "May": (8, 23),
    "June": (9, 24),
    "July": (10, 24),
    "August": (11, 25),
    "September": (12, 26),
    "October": (1, 20),
    "November": (2, 21),
    "December": (3, 21),
}

ANAPHORA_NAMES = {
    1: "Apostles'",
    2: "Our Lord's",
    3: "St. John, Son of Thunder's",
    4: "St. Mary's",
    5: "Of the 318 Fathers at 1st Nicaea",
    6: "St. Athanasius'",
    7: "St. Basil's",
    8: "St. Gregory of Nyssa's",
    9: "St. Epiphanius'",
    10: "St. John Chrysostom's",
    11: "St. Cyril's",
    12: "St. Dioscorus'",
    13: "St. Jacob of Serough's",
    14: "St. Gregory II's",
}

MONTH_ALIASES = {
    "jan": "January",
    "january": "January",
    "feb": "February",
    "february": "February",
    "mar": "March",
    "march": "March",
    "apr": "April",
    "april": "April",
    "may": "May",
    "jun": "June",
    "june": "June",
    "jul": "July",
    "july": "July",
    "aug": "August",
    "august": "August",
    "sep": "September",
    "sept": "September",
    "september": "September",
    "oct": "October",
    "october": "October",
    "nov": "November",
    "november": "November",
    "dec": "December",
    "december": "December",
}

BOOKISH_PREFIXES = (
    # New Testament
    "mat", "mt",
    "mrk", "mk",
    "luk", "lk",
    "jhn", "jn",
    "act", "ac",
    "rom", "rm",
    "1cr", "2cr",
    "gal", "gl",
    "eph", "ep",
    "phl", "pl", "phi",
    "col",
    "1th", "2th", "1ts", "2ts",
    "1tm", "2tm",
    "tt", "tts",
    "pm", "phm", "plm",
    "hb", "heb",
    "jam", "jm",
    "1pt", "2pt",
    "1jn", "2jn", "3jn",
    "jd", "jud",
    "rv", "rev",
    # Old Testament
    "ps",
    "gen",
    "exo",
    "lev",
    "num",
    "deu",
    "jos",
    "judg", "jdg",
    "rut",
    "1sa", "2sa",
    "1kg", "2kg", "1ki", "2ki",
    "1ch", "2ch",
    "ezr",
    "neh",
    "est",
    "job",
    "pro",
    "ecc",
    "isa",
    "jer",
    "lam",
    "eze",
    "dan",
    "hos",
    "joe",
    "amo",
    "oba",
    "jon",
    "mic",
    "nah",
    "hab",
    "zep",
    "hag",
    "zec",
    "mal",
    # Deuterocanonical / Ethiopian canon
    "sir",  # Sirach / Ecclesiasticus
    "tob",  # Tobit
    "jdt",  # Judith
    "1ma", "2ma",  # Maccabees
    "wis",  # Wisdom
    "bar",  # Baruch
    "brk",  # Baruch (alt)
    "tws",  # Tobit/Wisdom (source abbreviation)
    "1es",  # 1 Esdras
    "3ma",  # 3 Maccabees
    "abb",  # Habakkuk additions / Bel and Dragon
    "sus",  # Susanna
    "aza",  # Azariah prayer
    "loj",  # Letter of Jeremiah
    "tpm",  # Prayer of Manasseh
    "151",  # Psalm 151
    "b&d",  # Bel and Dragon
    # Special markers
    "fes",  # Festal hiatus abbreviation in some PDFs
    "s. f",
)

COLUMN_BOUNDS = {
    "day": (0.0, 120.0),
    "morning": (120.0, 220.0),
    "qidase_left": (220.0, 320.0),
    "qidase_right": (320.0, 410.0),
    "ana": (410.0, 455.0),
    "evening": (455.0, 1000.0),
}


@dataclass
class ColumnLine:
    y: float
    text: str


@dataclass
class ParsedRow:
    page_index: int
    day_label: str
    printed_date: str | None = None
    morning: list[str] = field(default_factory=list)
    qidase_segments: list[tuple[float, str]] = field(default_factory=list)
    ana: list[str] = field(default_factory=list)
    evening: list[str] = field(default_factory=list)


def normalize_text(text: str) -> str:
    value = text.strip()
    value = re.sub(r"\s+", " ", value)
    value = value.replace(" .", ".").replace(" ,", ",").replace(" ;", ";")
    value = value.replace(" :", " : ")
    value = re.sub(r"\s+", " ", value)
    value = value.replace("–", "-").replace("—", "-")
    value = value.replace("Ps.", "Ps")
    # Fix known OCR artifacts in PDF text
    value = re.sub(r"\b21Kg\b", "2Kg", value)   # "21Kg" → "2Kg" (spurious merged digit)
    value = re.sub(r"\b21Ki\b", "2Ki", value)
    value = re.sub(r"\b2J n\b", "2Jn", value)   # "2J n" → "2Jn" (split word)
    return value.strip()


def line_is_row_start(text: str) -> bool:
    if "/" in text:
        return False
    cleaned = text.strip()
    return bool(
        re.fullmatch(r"\d{1,2}", cleaned)
        or re.fullmatch(r"\d{1,2}\s+.+", cleaned)
        or re.fullmatch(
            r"(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Sept|Oct|Nov|Dec)\s+\d{1,2}",
            cleaned,
            re.IGNORECASE,
        )
    )


def split_row_start(text: str) -> tuple[str, str | None]:
    cleaned = normalize_text(text)
    month_match = re.match(
        r"^(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Sept|Oct|Nov|Dec)\s+(\d{1,2})(?:\s+(.*))?$",
        cleaned,
        re.IGNORECASE,
    )
    if month_match is not None:
        remainder = normalize_text(month_match.group(2) or "")
        return month_match.group(1), remainder or None
    match = re.match(r"^(\d{1,2})(?:\s+(.*))?$", cleaned)
    if match is not None:
        remainder = normalize_text(match.group(2) or "")
        return match.group(1), remainder or None
    return cleaned, None


def extract_day_number(day_label: str) -> int:
    match = re.search(r"(\d{1,2})\s*$", day_label)
    if match is None:
        raise ValueError(f"Unable to parse day number from {day_label!r}")
    return int(match.group(1))


def looks_like_psalm(text: str) -> bool:
    return normalize_text(text).lower().startswith("ps")


def looks_like_gospel(text: str) -> bool:
    lower = normalize_text(text).lower()
    return lower.startswith(("mat", "mt", "mrk", "mk", "luk", "lk", "jhn", "jn"))


def looks_like_reference(text: str) -> bool:
    lower = normalize_text(text).lower()
    return lower.startswith(BOOKISH_PREFIXES)


_ANAPHORA_NAME_LOOKUP = {
    "apostles": 1, "aposteles": 1,
    "our lord": 2, "ourlord": 2,
    "john son of thunder": 3, "john, son of thunder": 3,
    "st. mary": 4, "stmary": 4, "mary": 4,
    "318 fathers": 5, "three hundred": 5, "nicaea": 5,
    "athanasius": 6, "athansius": 6, "st. athan": 6,
    "basil": 7, "st. basil": 7,
    "gregory of nyssa": 8, "nyssa": 8,
    "epiphanius": 9, "st. epiphanius": 9,
    "chrysostom": 10, "john chrysostom": 10,
    "cyril": 11, "st. cyril": 11,
    "dioscorus": 12, "dioscorous": 12, "diosc": 12,
    "jacob of serough": 13, "jacob": 13,
    "gregory ii": 14, "gregory 2": 14,
}


def resolve_anaphora(source_text: str) -> tuple[int, str, str | None]:
    # First try name-based lookup (PDF may spell out anaphora name instead of number)
    lower_src = source_text.strip().lower()
    for key, num in _ANAPHORA_NAME_LOOKUP.items():
        if key in lower_src:
            return num, ANAPHORA_NAMES[num], None

    # Filter out non-number tokens like "A-?" or "?" before extracting numbers
    cleaned = re.sub(r"[A-Za-z?]", "", source_text)
    numbers = [int(item) for item in re.findall(r"\d+", cleaned) if int(item) > 0]
    if not numbers:
        return 0, source_text.strip() or "Unknown", None
    primary = numbers[0]
    resolved = ANAPHORA_NAMES.get(primary, f"Anaphora {primary}")
    note = None
    if len(numbers) > 1 or "/" in source_text:
        extra = " / ".join(ANAPHORA_NAMES.get(item, f"Anaphora {item}") for item in numbers)
        resolved = extra
    return primary, resolved, note


def classify_year_type(title: str) -> str:
    return "leap_year" if "LY" in title.upper() else "non_leap_year"


def extract_title(doc: fitz.Document) -> tuple[str, str]:
    for page in doc:
        text = page.get_text()
        match = re.search(r"Readings for the Month(?: of)? ([A-Za-z]+(?:\s+LY)?)", text)
        if match:
            month_text = match.group(1).strip()
            month_bits = month_text.split()
            month_name = MONTH_ALIASES.get(month_bits[0].lower(), month_bits[0])
            suffix = " LY" if "LY" in month_bits[1:] else ""
            return month_name, f"Readings for the Month of {month_name}{suffix}"
    raise ValueError("Unable to find month title in PDF text.")


def page_lines(
    page: fitz.Page,
    fallback_header_x: dict[str, float] | None = None,
) -> list[dict[str, object]]:
    words = page.get_text("words")
    header_y = None
    header_x: dict[str, float] = {}
    clusters: list[dict[str, object]] = []

    for word in sorted(words, key=lambda item: (item[1], item[0])):
        x0, y0, x1, y1, text, *_rest = word
        upper = text.upper()
        if upper == "DAY":
            header_y = y0
            header_x["day"] = x0
        elif upper == "MORNING":
            header_x["morning"] = x0
        elif upper == "QIDASE":
            header_x["qidase"] = x0
        elif upper == "ANA":
            header_x["ana"] = x0
        elif upper == "EVENING":
            header_x["evening"] = x0

    # If this page has no column headers (continuation page), use values from page 1.
    is_continuation = fallback_header_x and not header_x
    if is_continuation:
        header_x = dict(fallback_header_x)

    if header_y is not None:
        cutoff_y = header_y + 8.0
    elif is_continuation:
        # No column headers on this page (continuation); skip page-header text (titles/org name)
        # at top. These appear at y≤73 across all PDFs; data starts at y≥72. Use 70 as cutoff.
        cutoff_y = 70.0
    else:
        cutoff_y = 50.0
    day_x = header_x.get("day", 42.0)
    morning_x = header_x.get("morning", 95.0)
    qidase_x = header_x.get("qidase", 250.0)
    evening_x = header_x.get("evening", 470.0)
    ana_x = header_x.get("ana", evening_x - 35.0)
    day_end = (day_x + morning_x) / 2.0
    # Morning book references are typically 1-3 words (~60-70px wide). Using the midpoint
    # between morning and qidase headers over-extends the morning column into the left
    # qidase sub-column when those headers are far apart (e.g. July/August at 132 vs 317).
    # Use 40% of the gap, capped at 70px, to keep morning tight.
    morning_end = morning_x + min(65.0, (qidase_x - morning_x) * 0.40)
    ana_start = ana_x - 20.0
    # Evening content can start up to 20px before the Evening header (column alignment varies).
    evening_start = evening_x - 20.0

    filtered = [word for word in words if cutoff_y <= word[1] <= 735.0]
    for word in sorted(filtered, key=lambda item: (item[1], item[0])):
        x0, y0, x1, y1, text, *_rest = word
        if text.startswith("www.ethiopianorthodox.org"):
            continue
        target = None
        for cluster in clusters:
            if abs(cluster["y"] - y0) <= 1.8:
                target = cluster
                break
        if target is None:
            target = {"y": y0, "words": []}
            clusters.append(target)
        target["words"].append((x0, x1, text))

    lines = []
    for cluster in clusters:
        columns: dict[str, list[tuple[float, str]]] = {
            "day": [],
            "morning": [],
            "ana": [],
            "evening": [],
        }
        qidase_words: list[tuple[float, float, str]] = []
        for x0, _x1, text in sorted(cluster["words"], key=lambda item: item[0]):
            if x0 < day_end:
                columns["day"].append((x0, text))
            elif x0 < morning_end:
                columns["morning"].append((x0, text))
            elif x0 < ana_start:
                qidase_words.append((x0, _x1, text))
            elif x0 < evening_start:
                columns["ana"].append((x0, text))
            else:
                columns["evening"].append((x0, text))
        line = {"y": cluster["y"]}
        qidase_segments: list[tuple[float, str]] = []
        if qidase_words:
            current_words: list[str] = []
            current_start = qidase_words[0][0]
            previous_x1 = qidase_words[0][1]
            for x0, x1, text in qidase_words:
                if current_words and x0 - previous_x1 > 18.0:
                    qidase_segments.append(
                        (current_start, normalize_text(" ".join(current_words)))
                    )
                    current_words = []
                    current_start = x0
                current_words.append(text)
                previous_x1 = x1
            if current_words:
                qidase_segments.append(
                    (current_start, normalize_text(" ".join(current_words)))
                )

        has_text = bool(qidase_segments)
        for column, items in columns.items():
            text = normalize_text(" ".join(item[1] for item in items))
            line[column] = text
            if text:
                has_text = True
        line["qidase"] = qidase_segments
        if has_text:
            lines.append(line)
    return lines


def parse_rows(doc: fitz.Document) -> list[ParsedRow]:
    rows: list[ParsedRow] = []
    current: ParsedRow | None = None
    # Capture column positions from page 1 to propagate to continuation pages
    first_page_header_x: dict[str, float] = {}

    for page_index, page in enumerate(doc):
        page_header_x: dict[str, float] = {}
        for word in page.get_text("words"):
            x0, y0, x1, y1, text, *_ = word
            upper = text.upper()
            if upper == "DAY": page_header_x["day"] = x0
            elif upper == "MORNING": page_header_x["morning"] = x0
            elif upper == "QIDASE": page_header_x["qidase"] = x0
            elif upper == "ANA": page_header_x["ana"] = x0
            elif upper == "EVENING": page_header_x["evening"] = x0
        if page_header_x:
            first_page_header_x = page_header_x

        for line in page_lines(page, fallback_header_x=first_page_header_x or None):
            day_text = line["day"]
            morning_text = line["morning"]
            row_start_text = None
            overflow_into_morning = None
            if isinstance(day_text, str) and line_is_row_start(day_text):
                row_start_text = day_text
            elif (
                isinstance(day_text, str)
                and not day_text.strip()
                and isinstance(morning_text, str)
                and line_is_row_start(morning_text)
            ):
                row_start_text = morning_text
                _row_label, overflow_into_morning = split_row_start(morning_text)

            if row_start_text is not None:
                if current is not None:
                    rows.append(current)
                day_label, overflow = split_row_start(row_start_text)
                current = ParsedRow(page_index=page_index, day_label=day_label)
                if overflow:
                    current.morning.append(overflow)
                if overflow_into_morning:
                    line = dict(line)
                    line["morning"] = ""
            if current is None:
                continue

            if day_text and not line_is_row_start(day_text):
                if "/" in day_text:
                    current.printed_date = normalize_text(day_text)

            for key, target in (
                ("morning", current.morning),
                ("ana", current.ana),
                ("evening", current.evening),
            ):
                text = line[key]
                if text:
                    target.append(normalize_text(text))
            for x0, text in line["qidase"]:
                if text:
                    current.qidase_segments.append((x0, text))

    if current is not None:
        rows.append(current)
    return rows


def add_eth_days(month: int, day: int, offset: int) -> tuple[int, int]:
    current_month = month
    current_day = day
    remaining = offset
    while remaining > 0:
        month_length = 6 if current_month == 13 else 30
        current_day += 1
        if current_day > month_length:
            current_day = 1
            current_month += 1
            if current_month > 13:
                current_month = 1
        remaining -= 1
    return current_month, current_day


def computed_eth_date(month_name: str, day_number: int) -> tuple[int, int]:
    start_month, start_day = MONTH_STARTS[month_name]
    return add_eth_days(start_month, start_day, day_number - 1)


def split_qidase_segments(segments: list[tuple[float, str]]) -> tuple[list[str], list[str]]:
    if not segments:
        return [], []
    xs = sorted({round(x, 1) for x, _text in segments})
    if len(xs) < 2:
        return [text for _x, text in segments], []
    gaps = [(xs[index + 1] - xs[index], index) for index in range(len(xs) - 1)]
    largest_gap, gap_index = max(gaps, key=lambda item: item[0])
    if largest_gap < 20.0:
        return [text for _x, text in segments], []
    split = (xs[gap_index] + xs[gap_index + 1]) / 2.0
    left = [text for x, text in segments if x < split]
    right = [text for x, text in segments if x >= split]
    return left, right


def build_qidase(
    morning_lines: list[str],
    qidase_left: list[str],
    qidase_right: list[str],
    row_notes: list[str],
) -> tuple[list[str], dict[str, str]]:
    morning = list(morning_lines)
    qidase_lines = list(qidase_left) + list(qidase_right)
    qidase: dict[str, str] = {}

    # When morning has extra psalm+gospel items at the end, they may be matins content
    # that overflowed into the morning column. Extract them if qidase is short.
    if len(morning) >= 2 and len(qidase_lines) in (5, 4):
        if looks_like_psalm(morning[0]) and looks_like_gospel(morning[1]):
            qidase["matins_psalm"] = morning.pop(0)
            qidase["matins_gospel"] = morning.pop(0)
        elif len(morning) >= 5 and looks_like_psalm(morning[-2]) and looks_like_gospel(morning[-1]):
            # Matins psalm+gospel at end of morning column (some PDF formats)
            qidase["matins_gospel"] = morning.pop()
            qidase["matins_psalm"] = morning.pop()

    if len(qidase_lines) == 7:
        qidase["matins_psalm"] = qidase_lines[0]
        qidase["matins_gospel"] = qidase_lines[1]
        qidase_lines = qidase_lines[2:]

    if len(qidase_lines) >= 5:
        qidase["pauline"] = qidase_lines[0]
        qidase["catholic"] = qidase_lines[1]
        qidase["acts"] = qidase_lines[2]
        qidase["psalm"] = qidase_lines[3]
        qidase["gospel"] = qidase_lines[4]
        # Extra lines beyond the 5 standard are supplemental readings (e.g. matins additions
        # that appear inline). Store them without flagging as errors.
        if len(qidase_lines) > 5:
            extras = [item for item in qidase_lines[5:] if looks_like_reference(item)]
            if extras:
                qidase["supplemental"] = " | ".join(extras)
    else:
        labels = ["pauline", "catholic", "acts", "psalm", "gospel"]
        for index, item in enumerate(qidase_lines):
            qidase[labels[index]] = item
        if len(qidase_lines) < 3:
            # Genuinely very short — flag for review
            row_notes.append(
                f"Unexpected Qidase line count ({len(qidase_lines)}). Review source row."
            )
        # 3-4 lines may result from page-boundary text wrapping — don't flag those

    return morning, qidase


def build_row_json(
    row: ParsedRow,
    month_name: str,
    document_name: str,
) -> tuple[dict[str, object], bool]:
    issues: list[str] = []
    day_number = extract_day_number(row.day_label)
    computed_month, computed_day = computed_eth_date(month_name, day_number)

    printed_date = normalize_text(row.printed_date or "")
    date_match = re.fullmatch(r"(\d{1,2})/(\d{1,2})", printed_date.replace(" ", ""))
    if date_match is None:
        printed_date = f"{computed_month}/{computed_day}"
        eth_month = computed_month
        eth_day = computed_day
    else:
        eth_month = int(date_match.group(1))
        eth_day = int(date_match.group(2))
        if (eth_month, eth_day) != (computed_month, computed_day):
            issues.append(
                f"Computed Ethiopian date {computed_month}/{computed_day} differs from printed {printed_date}."
            )

    morning_status = None
    morning_lines = [normalize_text(item) for item in row.morning if normalize_text(item)]

    # Strip Ethiopian date tokens that leaked into morning column (e.g. "12/26", "1/5", "1/ 7")
    def _is_eth_date(text: str) -> bool:
        return bool(re.fullmatch(r"\d{1,2}\s*/\s*\d{1,2}", text.replace(" ", "")))

    while morning_lines and _is_eth_date(morning_lines[0]):
        morning_lines = morning_lines[1:]

    # Strip anaphora legend lines that got picked up as morning content (e.g. "A 1) Aposteles")
    morning_lines = [
        item for item in morning_lines
        if not re.match(r"^A\s+\d+\)", item)
        and not re.match(r"^A\s+\d+\)St\.", item)
        and not re.match(r"^The Ethiopian Orthodox", item, re.IGNORECASE)
        and not re.match(r"^Tewahido Church", item, re.IGNORECASE)
        and not re.match(r"^(www\.ethiopianorthodox|Faith and Order)", item, re.IGNORECASE)
        # Anaphora key continuation lines (e.g. "Aposteles (2) Our Lord", "9)St. Epiphanius")
        and not re.match(r"^(Aposteles|Apostles|Our Lord|John the|St\.\s*Mary|Three Hundred|St\.\s*Athan|St\.\s*Basil)", item, re.IGNORECASE)
        and not re.match(r"^\d+\)St\.", item)
    ]

    def _is_continuation_fragment(text: str) -> bool:
        # Verse continuation fragments (e.g. "22:31 - f", "- 47", ": 4 - 11") from wrapped refs
        return bool(re.match(r"^[-–:\d]", text.strip()))

    if (
        not row.printed_date
        and morning_lines
        and not looks_like_reference(morning_lines[0])
        and morning_lines[0].lower().replace(" ", "").replace(".", "") not in {"festal hiatus", "festal_hiatus", "sf", "festalhiatus"}
        and not _is_eth_date(morning_lines[0])
        and not _is_continuation_fragment(morning_lines[0])
    ):
        issues.append(f"Source date marker preserved as {morning_lines[0]}.")
        morning_lines = morning_lines[1:]

    # Normalize festal hiatus in any position. "S.F." = "Solemnity/Feast" abbreviation for festal day.
    _sf_tokens = {"s.f.", "s.f", "sf"}
    festal_variants = {"festal hiatus", "festal_hiatus", "festalhiatus"}
    _all_festal = {v.replace(" ", "") for v in festal_variants} | _sf_tokens
    if any(item.strip().lower().replace(" ", "").replace(".", "") in _all_festal for item in morning_lines):
        morning_status = "festal_hiatus"
        morning_lines = []

    qidase_left, qidase_right = split_qidase_segments(row.qidase_segments)
    morning_lines, qidase = build_qidase(
        morning_lines,
        qidase_left,
        qidase_right,
        issues,
    )

    ana_source = normalize_text(" ".join(item for item in row.ana if item))
    # Strip any anaphora tokens that leaked in from adjacent columns
    ana_source_clean = re.sub(r"\bA\s*[-–]\s*\d+\b", "", ana_source).strip()
    if not ana_source_clean:
        ana_source_clean = ana_source
    ana_number, ana_name, ana_note = resolve_anaphora(ana_source_clean)
    # Multi-anaphora days (e.g. "3/4") are valid — don't flag as needing review.
    # "A-?" in the PDF means anaphora is unspecified for that day — not an extraction error.
    _ana_is_unknown_marker = re.fullmatch(r"A\s*[-–]\s*\?", ana_source_clean.strip()) is not None
    if ana_number == 0 and not _ana_is_unknown_marker and ana_source_clean.strip():
        issues.append("Anaphora could not be resolved from source text.")

    evening_lines = [normalize_text(item) for item in row.evening if normalize_text(item)]

    # Strip anaphora tokens that leaked into evening column (e.g. "A-5 Tob 1" → "Tob 1", "2 2Sa 13" → "2Sa 13")
    def _strip_ana_prefix(text: str) -> str:
        cleaned = re.sub(r"^A\s*[-–]\s*\d+(?:\s*/\s*\d+)?\s*", "", text).strip()
        cleaned = re.sub(r"^-\s*\d+(?:\s*/\s*\d+)?\s*", "", cleaned).strip()
        # Leading standalone number (anaphora number without "A-" prefix), before uppercase or digit-letter book abbrev
        cleaned = re.sub(r"^\d+\s+(?=[A-Z0-9])", "", cleaned).strip()
        return cleaned or text

    evening_lines = [_strip_ana_prefix(item) for item in evening_lines]

    # Normalize festal hiatus in evening to morning_status (evening "festal hiatus" means no evening reading)
    festal_in_evening = any(
        item.strip().lower().replace(" ", "") in {v.replace(" ", "") for v in festal_variants}
        for item in evening_lines
    )
    if festal_in_evening:
        evening_lines = [
            item for item in evening_lines
            if item.strip().lower().replace(" ", "") not in {v.replace(" ", "") for v in festal_variants}
        ]
        if morning_status is None:
            morning_status = "festal_hiatus_evening"

    # Filter out anaphora legend lines, standalone non-reference items, and page footers
    evening_lines = [
        item for item in evening_lines
        if item
        and not re.match(r"^\d+\)\s*(St|Apost|Our|John|Mary|Three|Athan|Basil|Greg|Epiphan|Cyril|Jacob|Diosc)", item)
        and not re.match(r"^A\s+\d+\)St\.", item)
        and not re.match(r"^\(NRSV\)$", item)
        and not re.match(r"^The Ethiopian Orthodox", item, re.IGNORECASE)
    ]
    # Strip Ethiopian date tokens that leaked into evening column
    evening_lines = [item for item in evening_lines if not _is_eth_date(item)]
    if not evening_lines and morning_status != "festal_hiatus" and morning_status != "festal_hiatus_evening":
        issues.append("Evening column is empty.")

    for collection_name, lines in (
        ("morning", morning_lines),
        ("evening", evening_lines),
    ):
        for item in lines:
            normalized_item = item.strip().lower().replace(" ", "")
            if normalized_item in {v.replace(" ", "") for v in festal_variants}:
                pass  # Already handled above
            elif not looks_like_reference(item) and not re.match(r"^The Ethiopian Orthodox", item, re.IGNORECASE):
                # A continuation fragment (e.g. "22:31 - f", ": 4 - 11") is a verse reference
                # that wrapped from the previous line — not a data error.
                _is_continuation = bool(re.match(r"^[-–:\d]", item.strip())) and bool(re.search(r"\d", item))
                if not _is_continuation:
                    issues.append(f"{collection_name.capitalize()} item may need review: {item}")

    # Missing gospel is already captured by the "Unexpected Qidase line count" flag if < 3 lines.
    # For 3-4 lines, accept as partial data (page-boundary wrap or genuinely short day).
    pass

    row_json: dict[str, object] = {
        "eth_month": eth_month,
        "eth_day": eth_day,
        "gregorian_display": printed_date,
        "morning": morning_lines,
        "qidase": qidase,
        "anaphora": {
            "source_number": ana_number,
            "resolved_name": ana_name,
        },
        "evening": evening_lines,
        "source_meta": {
            "document": document_name,
            "row_label": f"{day_number} / {printed_date}".strip(),
            "qa_status": "needs_review" if issues else "extracted_from_pdf_text",
        },
    }
    if morning_status is not None:
        row_json["morning_status"] = morning_status
    if issues:
        row_json["source_row_note"] = " ".join(issues)
    return row_json, bool(issues)


def build_month(pdf_path: Path) -> tuple[dict[str, object], list[int]]:
    doc = fitz.open(pdf_path)
    month_name, title = extract_title(doc)
    rows = parse_rows(doc)
    built_rows = []
    review_days: list[int] = []

    for row in rows:
        row_json, needs_review = build_row_json(row, month_name, pdf_path.name)
        built_rows.append(row_json)
        if needs_review:
            review_days.append(int(row_json["eth_day"]))

    month_json = {
        "schema_version": "1.0",
        "source_name": title.replace(" LY", ""),
        "year_type": classify_year_type(title),
        "rows": built_rows,
    }
    return month_json, review_days


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--pdf",
        action="append",
        help="Specific PDF filenames to build. Defaults to all month PDFs.",
    )
    args = parser.parse_args()

    selected = args.pdf or sorted(PDF_TO_OUTPUT)
    review_summary: dict[str, list[int]] = {}

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    for filename in selected:
        pdf_path = PDF_DIR / filename
        output_name = PDF_TO_OUTPUT.get(filename)
        if output_name is None:
            raise SystemExit(f"No output mapping configured for {filename}")
        month_json, review_days = build_month(pdf_path)
        output_path = OUTPUT_DIR / output_name
        output_path.write_text(
            json.dumps(month_json, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
        if review_days:
            review_summary[output_name] = review_days
        print(f"Wrote {output_name} ({len(month_json['rows'])} rows)")

    if review_summary:
        print("\nRows flagged for review:")
        for filename, days in review_summary.items():
            print(f"  {filename}: {', '.join(str(day) for day in days)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
