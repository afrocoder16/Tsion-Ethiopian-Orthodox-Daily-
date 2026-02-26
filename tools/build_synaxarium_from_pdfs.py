#!/usr/bin/env python3
"""Build Synaxarium JSON assets from daily PDF files.

Input:  assets/synaxarium_pdfs/Month_DD.pdf
Output: assets/data/synaxarium_entries.json
        assets/data/synaxarium_index.json
        assets/data/synaxarium_needs_review.json
"""

from __future__ import annotations

import argparse
import json
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

import fitz  # PyMuPDF


_TITLE_PATTERNS = [
    re.compile(
        r"\b(?:Saint|St\.?)\s+([A-Z][A-Za-z'’\-]+(?:\s+[A-Z][A-Za-z'’\-]+){0,4})",
        flags=re.IGNORECASE,
    ),
    re.compile(
        r"\bAbba\s+([A-Z][A-Za-z'’\-]+(?:\s+[A-Z][A-Za-z'’\-]+){0,4})",
        flags=re.IGNORECASE,
    ),
    re.compile(
        r"\bArchangel\s+([A-Z][A-Za-z'’\-]+(?:\s+[A-Z][A-Za-z'’\-]+){0,4})",
        flags=re.IGNORECASE,
    ),
    re.compile(
        r"\bProphet\s+([A-Z][A-Za-z'’\-]+(?:\s+[A-Z][A-Za-z'’\-]+){0,4})",
        flags=re.IGNORECASE,
    ),
]

_MONTH_ALIASES = {
    "hidar": "Hidar",
    "hedar": "Hidar",
    "tahisas": "Tahisas",
    "tahsas": "Tahisas",
    "tekemt": "Tekemt",
    "teqemt": "Tekemt",
    "tir": "Tir",
    "ter": "Tir",
    "yekatit": "Yekatit",
    "meskerem": "Meskerem",
    "ginbot": "Ginbot",
    "hamle": "Hamle",
    "megabit": "Megabit",
    "miyazia": "Miyazia",
    "sene": "Senne",
    "senne": "Senne",
    "nehasse": "Nehasse",
    "nehase": "Nehasse",
    "pagumen": "Pagumen",
    "pagume": "Pagumen",
}


@dataclass(frozen=True)
class ParsedFileName:
    month: str
    day: int
    key: str


def _normalize_month(month_token: str) -> str:
    normalized = _MONTH_ALIASES.get(month_token.strip().lower())
    if normalized:
        return normalized
    token = month_token.strip()
    return token[:1].upper() + token[1:].lower()


def _parse_filename(pdf_path: Path) -> ParsedFileName:
    stem = pdf_path.stem
    parts = stem.split("_")
    if len(parts) != 2:
        raise ValueError(f"Invalid filename format: {pdf_path.name}")
    month = _normalize_month(parts[0])
    day = int(parts[1])
    return ParsedFileName(
        month=month,
        day=day,
        key=f"{month}-{day:02d}",
    )


def _extract_text(pdf_path: Path) -> str:
    doc = fitz.open(str(pdf_path))
    chunks: list[str] = []
    for page in doc:
        text = page.get_text("text") or ""
        if text.strip():
            chunks.append(text.strip())
    doc.close()
    return "\n\n".join(chunks).strip()


def _split_sections(full_text: str) -> list[str]:
    text = re.sub(r"\s+", " ", full_text).strip()
    if not text:
        return []
    sections = re.split(r"(?=On this day\b)", text, flags=re.IGNORECASE)
    cleaned = [item.strip() for item in sections if item.strip()]
    if not cleaned:
        return [text]
    return cleaned


def _normalize_name(raw: str) -> str:
    name = re.sub(r"\s+", " ", raw).strip(" .,:;")
    name = re.sub(r"^(?:our|the|holy|great|father)\s+", "", name, flags=re.IGNORECASE)
    name = re.sub(r"^(?:our|the|holy|great|father)\s+", "", name, flags=re.IGNORECASE)
    name = re.sub(
        r"\b(?:who|which|when|where|and|that|for|because|became|was|is)\b.*$",
        "",
        name,
        flags=re.IGNORECASE,
    ).strip()
    name = re.sub(r"\b(?:of|the|our|holy|great|father)$", "", name, flags=re.IGNORECASE).strip()
    if name.lower() in {"lady", "our holy lady"}:
        return "Virgin Mary"
    if name.lower().startswith("lady "):
        return "Virgin Mary"
    return name


def _extract_name_from_section(section: str) -> str | None:
    first_sentence = section.split(".", 1)[0]
    first_sentence = re.sub(r"\s+", " ", first_sentence).strip()
    for pattern in _TITLE_PATTERNS:
        match = pattern.search(first_sentence)
        if not match:
            continue
        candidate = _normalize_name(match.group(1))
        if candidate and candidate.lower() not in {"lady", "woman", "spirit"}:
            return candidate

    if re.search(r"\b(Virgin Mariyam|Virgin Mary|Holy Virgin Mary|Mariyam)\b", first_sentence, flags=re.IGNORECASE):
        return "Virgin Mary"

    generic = re.search(
        r"On this day\s+(?:died|appeared|became|are commemorated|took place(?: the)?(?: birth|assumption|commemoration)? of)\s+"
        r"(?:the\s+)?(?:holy\s+)?(?:great\s+)?([A-Z][A-Za-z'’\-]+(?:\s+[A-Z][A-Za-z'’\-]+){0,4})",
        first_sentence,
        flags=re.IGNORECASE,
    )
    if generic:
        candidate = _normalize_name(generic.group(1))
        if candidate and candidate.lower() not in {"lady", "woman", "spirit"}:
            return candidate
    return None


def _extract_saint_names(full_text: str) -> list[str]:
    names: list[str] = []
    sections = _split_sections(full_text)
    for section in sections:
        candidate = _extract_name_from_section(section)
        if candidate:
            names.append(candidate)

    # Fallback: first strong "Saint <Name>" near the top.
    if not names:
        top = full_text[:1400]
        fallback = re.search(
            r"\b(?:Saint|St\.?|Abba|Archangel|Prophet)\s+([A-Z][A-Za-z'’\-]+(?:\s+[A-Z][A-Za-z'’\-]+){0,5})",
            top,
            flags=re.IGNORECASE,
        )
        if fallback:
            candidate = _normalize_name(fallback.group(1))
            if candidate:
                names.append(candidate)

    deduped: list[str] = []
    seen: set[str] = set()
    for name in names:
        key = name.lower()
        if key in seen:
            continue
        seen.add(key)
        deduped.append(name)
    return deduped


def _build_entries(pdf_paths: Iterable[Path]) -> tuple[dict, dict, list[dict]]:
    entries: dict[str, dict] = {}
    index: dict[str, dict] = {}
    needs_review: list[dict] = []

    for pdf_path in sorted(pdf_paths):
        parsed = _parse_filename(pdf_path)
        full_text = _extract_text(pdf_path)
        saints = _extract_saint_names(full_text)
        primary = saints[0] if saints else None
        review = (not full_text.strip()) or (primary is None)
        if review:
            needs_review.append(
                {
                    "key": parsed.key,
                    "source_file": pdf_path.name,
                    "reason": "empty_text" if not full_text.strip() else "no_primary_saint",
                }
            )
        entries[parsed.key] = {
            "month": parsed.month,
            "day": parsed.day,
            "primary_saint": primary,
            "saints": saints,
            "text": full_text,
            "source_file": pdf_path.name,
            "needs_review": review,
        }
        index[parsed.key] = {
            "primary_saint": primary,
            "saints": saints,
            "needs_review": review,
            "source_file": pdf_path.name,
        }
    return entries, index, needs_review


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--pdf-dir",
        default="assets/synaxarium_pdfs",
        help="Directory containing Month_DD.pdf files",
    )
    parser.add_argument(
        "--out-dir",
        default="assets/data",
        help="Directory for generated JSON files",
    )
    args = parser.parse_args()

    pdf_dir = Path(args.pdf_dir)
    out_dir = Path(args.out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    pdf_paths = list(pdf_dir.glob("*.pdf"))
    entries, index, needs_review = _build_entries(pdf_paths)

    entries_payload = {"schema_version": "1.0", "entries": entries}
    index_payload = {"schema_version": "1.0", "index": index}
    review_payload = {
        "schema_version": "1.0",
        "count": len(needs_review),
        "items": needs_review,
    }

    (out_dir / "synaxarium_entries.json").write_text(
        json.dumps(entries_payload, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    (out_dir / "synaxarium_index.json").write_text(
        json.dumps(index_payload, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    (out_dir / "synaxarium_needs_review.json").write_text(
        json.dumps(review_payload, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    print(
        f"Generated {len(entries)} entries, {len(index)} index rows, "
        f"{len(needs_review)} needs_review items."
    )


if __name__ == "__main__":
    main()
