#!/usr/bin/env python3
"""Build structured Synaxarium month JSON files from daily PDFs.

This generator uses the existing structured Meskerem file as the schema and
style reference, reads the curated main-commemoration DOCX for day-level
primary labels, and extracts day text from the source PDFs.
"""

from __future__ import annotations

import argparse
import json
import re
import zipfile
from dataclasses import dataclass
from html import unescape
from pathlib import Path
from typing import Iterable

import fitz  # PyMuPDF


EXPECTED_MONTH_DAYS = {
    "Meskerem": 30,
    "Tekemt": 30,
    "Hedar": 30,
    "Tahisas": 30,
    "Tir": 30,
    "Yekatit": 30,
    "Megabit": 30,
    "Miyazia": 30,
    "Ginbot": 30,
    "Senne": 30,
    "Hamle": 30,
    "Nehasse": 30,
    "Pagumen": 6,
}

MONTH_ALIASES = {
    "meskerem": "Meskerem",
    "tekemt": "Tekemt",
    "teqemt": "Tekemt",
    "hedar": "Hedar",
    "hidar": "Hedar",
    "tahisas": "Tahisas",
    "tahsas": "Tahisas",
    "tir": "Tir",
    "ter": "Tir",
    "yekatit": "Yekatit",
    "megabit": "Megabit",
    "miyazia": "Miyazia",
    "miyazya": "Miyazia",
    "ginbot": "Ginbot",
    "senne": "Senne",
    "sene": "Senne",
    "hamle": "Hamle",
    "nehasse": "Nehasse",
    "nehase": "Nehasse",
    "pagumen": "Pagumen",
    "pagume": "Pagumen",
}

SECTION_START_RE = re.compile(
    r"(?=(?:On this day|And on this day)(?: also)?(?: are| is| became| died| was| took| "
    r"the translation| the birth| celebrated| commemorated))",
    flags=re.IGNORECASE,
)

TITLE_PATTERNS = [
    re.compile(
        r"\b(Saint\s+[A-Z][A-Za-z'’\-]+(?:\s+[A-Z][A-Za-z'’\-]+){0,6})",
        flags=re.IGNORECASE,
    ),
    re.compile(
        r"\b(Abba\s+[A-Z][A-Za-z'’\-]+(?:\s+[A-Z][A-Za-z'’\-]+){0,8})",
        flags=re.IGNORECASE,
    ),
    re.compile(
        r"\b(Prophet\s+[A-Z][A-Za-z'’\-]+(?:\s+[A-Z][A-Za-z'’\-]+){0,4})",
        flags=re.IGNORECASE,
    ),
    re.compile(
        r"\b([A-Z][A-Za-z'’\-]+(?:\s+the\s+[A-Z][A-Za-z'’\-]+){0,2}\s+Prophet)",
        flags=re.IGNORECASE,
    ),
]

EVENT_HINTS = (
    "council",
    "miracle",
    "festival",
    "translation",
    "birth",
    "consecration",
    "church",
    "cross",
    "commemoration",
)

MOJIBAKE_REPLACEMENTS = {
    "\u00a0": " ",
    "â€™": "’",
    "â€˜": "‘",
    "â€œ": "“",
    "â€": "”",
    "â€“": "–",
    "â€”": "—",
    "Ã©": "é",
    "Ã": "",
    "Â": "",
}


@dataclass(frozen=True)
class ParsedPdf:
    month: str
    day: int
    key: str
    filename: str


def normalize_month(token: str) -> str:
    normalized = MONTH_ALIASES.get(token.strip().lower())
    if normalized:
        return normalized
    cleaned = token.strip()
    return cleaned[:1].upper() + cleaned[1:].lower()


def parse_pdf_name(pdf_path: Path) -> ParsedPdf:
    parts = pdf_path.stem.split("_")
    if len(parts) != 2:
        raise ValueError(f"Invalid PDF filename: {pdf_path.name}")
    month = normalize_month(parts[0])
    day = int(parts[1])
    return ParsedPdf(month=month, day=day, key=f"{month}-{day:02d}", filename=pdf_path.name)


def load_meskerem_reference(path: Path) -> tuple[list[str], set[str]]:
    payload = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(payload, list) or not payload:
        raise ValueError("Structured Meskerem file must be a non-empty list.")
    ordered_keys = list(payload[0].keys())
    types = {
        item["type"]
        for day in payload
        for item in day.get("commemorations", [])
        if isinstance(item, dict) and item.get("type")
    }
    return ordered_keys, types


def load_primary_map(docx_path: Path) -> dict[str, str]:
    with zipfile.ZipFile(docx_path) as archive:
        raw = archive.read("word/document.xml").decode("utf-8", errors="ignore")
    text = unescape(re.sub(r"<[^>]+>", "\n", raw))
    lines = [line.strip() for line in re.sub(r"\n+", "\n", text).splitlines() if line.strip()]

    primary_by_key: dict[str, str] = {}
    for index, line in enumerate(lines[:-2]):
        match = re.match(
            r"^(meskerem|tekemt|hedar|hidar|tahisas|tahsas|tir|ter|yekatit|megabit|miyazia|"
            r"ginbot|senne|sene|hamle|nehasse|nehase|pagumen|pagume)\s+(\d{1,2})$",
            line.lower(),
        )
        if not match:
            continue
        month = normalize_month(match.group(1))
        day = int(match.group(2))
        key = f"{month}-{day:02d}"
        primary_by_key[key] = clean_name(lines[index + 1])
    return primary_by_key


def extract_pdf_text(pdf_path: Path) -> str:
    document = fitz.open(str(pdf_path))
    chunks: list[str] = []
    for page in document:
        text = page.get_text("text") or ""
        if text.strip():
            chunks.append(text.strip())
    document.close()
    return "\n\n".join(chunks).strip()


def normalize_text(text: str) -> str:
    for old, new in MOJIBAKE_REPLACEMENTS.items():
        text = text.replace(old, new)
    lines: list[str] = []
    for raw_line in text.replace("\r", "").split("\n"):
        line = raw_line.strip()
        if not line:
            continue
        if line in {"Back to", "list", "Next", "Previous"}:
            continue
        if re.match(r"^THE\s+[A-Z\s]+MONTH$", line):
            continue
        if re.match(r"^[A-Z][a-z]+ \d{2}$", line):
            continue
        if re.match(r"^\([A-Za-z]+\s+\d{1,2}\)$", line):
            continue
        lines.append(line)
    compact = " ".join(lines)
    compact = re.sub(r"\s+", " ", compact).strip()
    compact = re.sub(
        r"IN THE NAME OF THE FATHER AND THE SON AND THE HOLY SPIRIT,?\s*ONE GOD\.?\s*AMEN\.?",
        "IN THE NAME OF THE FATHER AND THE SON AND THE HOLY SPIRIT, ONE GOD. AMEN.",
        compact,
        flags=re.IGNORECASE,
    )
    compact = re.sub(
        r"\s+(?=(?:On this day|And on this day|Glory be to God))",
        "\n\n",
        compact,
    )
    return compact.strip()


def split_sections(cleaned_text: str) -> list[str]:
    sections = [part.strip() for part in SECTION_START_RE.split(cleaned_text) if part.strip()]
    if sections:
        if sections[0].startswith("IN THE NAME OF THE FATHER"):
            preface, *rest = sections
            rest.insert(0, preface)
            return rest
        return sections
    return [cleaned_text] if cleaned_text else []


def section_starts_with_commemoration(section: str) -> bool:
    lowered = section.lower()
    return lowered.startswith("on this day") or lowered.startswith("and on this day")


def clean_name(name: str) -> str:
    name = name.strip(" .,:;[]")
    name = re.sub(r"\s+", " ", name)
    return name


def infer_type(name: str, story: str, allowed_types: set[str]) -> str:
    name_lowered = name.lower()
    story_lowered = story.lower()
    lowered = f"{name_lowered} {story_lowered}"
    if "council" in name_lowered or "council" in story_lowered:
        return "council"
    if any(hint in name_lowered for hint in ("miracle", "portrait")) or (
        "miracle" in story_lowered and any(hint in name_lowered for hint in ("our lady", "mary", "raphael"))
    ):
        return "miracle"
    if any(hint in name_lowered for hint in ("festival", "translation", "birth", "consecration", "cross", "church")):
        return "event"
    if "apostle" in name_lowered:
        return "apostle"
    if "prophet" in name_lowered:
        return "prophet"
    if any(phrase in story_lowered for phrase in ("became a martyr", "became martyrs", "was martyred", "crown of martyrdom")):
        return "martyr"
    return "saint"


def title_from_first_sentence(sentence: str, primary_hint: str | None = None) -> str:
    sentence = clean_name(sentence)
    if primary_hint and sentence.lower().startswith(("on this day", "and on this day")):
        if any(hint in primary_hint.lower() for hint in EVENT_HINTS):
            return primary_hint

    if "general council" in sentence.lower():
        if "dionysius" in sentence.lower():
            return "The General Council under Abba Dionysius"
        return "The General Council"
    if "miracle" in sentence.lower():
        candidate = re.sub(r"^(?:On this day|And on this day)(?: also)?(?: was revealed| is commemorated| is celebrated)?\s+", "", sentence, flags=re.IGNORECASE)
        candidate = re.split(r"(?: when | because | for |,|;|\.)", candidate, maxsplit=1)[0]
        return clean_name(candidate)

    for pattern in TITLE_PATTERNS:
        match = pattern.search(sentence)
        if match:
            return clean_name(match.group(1))

    match = re.search(
        r"^(?:On this day|And on this day)(?: also)?\s+(?:died|became|was|is|are|took place)\s+(.*?)(?:,|;|\.| who | which | when )",
        sentence,
        flags=re.IGNORECASE,
    )
    if match:
        candidate = clean_name(match.group(1))
        candidate = re.sub(r"^(?:the|holy|great|righteous)\s+", "", candidate, flags=re.IGNORECASE)
        return candidate

    return primary_hint or "Unknown commemoration"


def build_commemorations(
    cleaned_text: str,
    primary_hint: str | None,
    allowed_types: set[str],
) -> tuple[list[dict[str, str]], str | None, bool, str | None]:
    sections = split_sections(cleaned_text)
    commemorations: list[dict[str, str]] = []
    review_reasons: list[str] = []

    commemoration_sections = [section for section in sections if section_starts_with_commemoration(section)]

    primary_tokens = {
        token.lower()
        for token in re.findall(r"[A-Za-z][A-Za-z'’\-]+", primary_hint or "")
        if len(token) > 2
    }

    for index, section in enumerate(commemoration_sections):
        first_sentence = section.split(".", 1)[0]
        suggested = primary_hint if index == 0 else None
        name = title_from_first_sentence(first_sentence, suggested)
        comm_type = infer_type(name, section, allowed_types)
        commemorations.append({"name": name, "type": comm_type, "story": section})

    if not commemorations:
        review_reasons.append("No commemorations could be extracted from the PDF text.")
        return [], primary_hint, True, "; ".join(review_reasons)

    primary = primary_hint or commemorations[0]["name"]
    if primary_hint:
        first_story = commemorations[0]["story"]
        first_name = commemorations[0]["name"]
        first_story_lower = first_story.lower()
        primary_supported = bool(primary_tokens) and all(
            token in first_story_lower for token in list(primary_tokens)[:2]
        )
        if first_name != primary_hint:
            commemorations[0]["name"] = primary_hint
            commemorations[0]["type"] = infer_type(primary_hint, first_story, allowed_types)
            review_reasons.append("Primary commemoration was normalized from the curated DOCX.")
        if not primary_supported:
            review_reasons.append("Primary commemoration does not clearly match the extracted first story.")

    if any("..." in item["story"] for item in commemorations):
        review_reasons.append("One or more stories appear truncated in the source text.")

    if any("â" in item["name"] or "â" in item["story"] for item in commemorations):
        review_reasons.append("Residual encoding artifacts remain in extracted text.")

    return commemorations, primary, bool(review_reasons), "; ".join(review_reasons) or None


def build_placeholder(month: str, day: int) -> dict[str, object]:
    return {
        "key": f"{month}-{day:02d}",
        "month": month,
        "day": day,
        "primary_saint": None,
        "commemorations": [],
        "day_source_file": None,
        "needs_review": True,
        "review_reason": "Missing source PDF for this day.",
    }


def build_record(
    pdf_path: Path,
    primary_map: dict[str, str],
    allowed_types: set[str],
) -> dict[str, object]:
    parsed = parse_pdf_name(pdf_path)
    raw_text = extract_pdf_text(pdf_path)
    cleaned_text = normalize_text(raw_text)
    primary_hint = primary_map.get(parsed.key)
    commemorations, primary, needs_review, review_reason = build_commemorations(
        cleaned_text,
        primary_hint,
        allowed_types,
    )
    return {
        "key": parsed.key,
        "month": parsed.month,
        "day": parsed.day,
        "primary_saint": primary,
        "commemorations": commemorations,
        "day_source_file": parsed.filename,
        "needs_review": needs_review,
        "review_reason": review_reason,
    }


def write_month_file(month: str, rows: list[dict[str, object]], out_dir: Path) -> Path:
    filename = f"{month.lower()}_synaxarium_structured.json"
    path = out_dir / filename
    path.write_text(json.dumps(rows, ensure_ascii=False, indent=2), encoding="utf-8")
    return path


def build_all_months(
    pdf_dir: Path,
    out_dir: Path,
    docx_path: Path,
    meskerem_path: Path,
    overwrite_existing: bool,
) -> list[Path]:
    out_dir.mkdir(parents=True, exist_ok=True)
    _, allowed_types = load_meskerem_reference(meskerem_path)
    allowed_types.update({"event", "miracle"})
    primary_map = load_primary_map(docx_path)

    pdf_lookup: dict[str, Path] = {}
    for pdf_path in sorted(pdf_dir.glob("*.pdf")):
        parsed = parse_pdf_name(pdf_path)
        pdf_lookup[parsed.key] = pdf_path

    written_files: list[Path] = []
    for month, total_days in EXPECTED_MONTH_DAYS.items():
        target = out_dir / f"{month.lower()}_synaxarium_structured.json"
        if month == "Meskerem" and target.exists() and not overwrite_existing:
            written_files.append(target)
            continue

        rows: list[dict[str, object]] = []
        for day in range(1, total_days + 1):
            key = f"{month}-{day:02d}"
            pdf_path = pdf_lookup.get(key)
            if pdf_path is None:
                rows.append(build_placeholder(month, day))
                continue
            rows.append(build_record(pdf_path, primary_map, allowed_types))
        written_files.append(write_month_file(month, rows, out_dir))
    return written_files


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--pdf-dir", required=True, help="Directory containing Month_DD.pdf files")
    parser.add_argument("--out-dir", required=True, help="Directory where month JSON files should be written")
    parser.add_argument("--docx-path", required=True, help="Curated main-commemoration DOCX path")
    parser.add_argument(
        "--meskerem-path",
        required=True,
        help="Structured Meskerem JSON path used as the schema/style template",
    )
    parser.add_argument(
        "--overwrite-existing",
        action="store_true",
        help="Overwrite any existing month files, including Meskerem.",
    )
    args = parser.parse_args()

    written = build_all_months(
        pdf_dir=Path(args.pdf_dir),
        out_dir=Path(args.out_dir),
        docx_path=Path(args.docx_path),
        meskerem_path=Path(args.meskerem_path),
        overwrite_existing=args.overwrite_existing,
    )
    for path in written:
        print(path)


if __name__ == "__main__":
    main()
