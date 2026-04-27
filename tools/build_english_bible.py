#!/usr/bin/env python3
"""
build_english_bible.py
Generates 81 English Bible JSON files at assets/80-weahadu-main/data/en/
matching the Amharic schema exactly.

Source waterfall per book:
  1. BSB  (Berean Standard Bible)    — 66 standard canon books
  2. KJVA (KJV with Apocrypha)       — deuterocanon + EOTC-adjacent books
  3. R.H. Charles Enoch (Gutenberg)  — Book of Enoch
  4. Placeholder                     — Jubilees, Admonition, Teref Baruch
"""

import io
import json
import os
import re
import sys
import urllib.request
from pathlib import Path

# Force UTF-8 output on Windows
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
SCRIPT_DIR   = Path(__file__).parent
PROJECT_ROOT = SCRIPT_DIR.parent
AM_DIR       = PROJECT_ROOT / 'assets' / '80-weahadu-main' / 'data' / 'am'
EN_DIR       = PROJECT_ROOT / 'assets' / '80-weahadu-main' / 'data' / 'en'
SOURCES_DIR  = SCRIPT_DIR / 'sources'
BSB_PATH     = SOURCES_DIR / 'BSB.json'
KJVA_PATH    = SOURCES_DIR / 'KJVA.json'
CHARLES_CACHE = SOURCES_DIR / 'charles_cache'

EN_DIR.mkdir(parents=True, exist_ok=True)
CHARLES_CACHE.mkdir(exist_ok=True)

# ---------------------------------------------------------------------------
# Mapping: Amharic book_name_en → scrollmapper book name
# None = handled by special logic or placeholder
# ---------------------------------------------------------------------------
EOTC_TO_SCROLL = {
    # Standard OT (BSB)
    'Genesis':              'Genesis',
    'Exodus':               'Exodus',
    'Leviticus':            'Leviticus',
    'Numbers':              'Numbers',
    'Deuteronomy':          'Deuteronomy',
    'Joshua':               'Joshua',
    'Judges':               'Judges',
    'Ruth':                 'Ruth',
    '1 Samuel':             'I Samuel',
    '2 Samuel':             'II Samuel',
    '1 Kings':              'I Kings',
    '2 Kings':              'II Kings',
    '1 Chronicles':         'I Chronicles',
    '2 Chronicles':         'II Chronicles',
    'Ezra':                 'Ezra',
    'Nehemiah':             'Nehemiah',
    'Esther':               'Esther',
    'Job':                  'Job',
    'Psalms':               'Psalms',
    'Proverbs':             'Proverbs',
    'Ecclesiastes':         'Ecclesiastes',
    'Song of Solomon':      'Song of Solomon',
    'Isaiah':               'Isaiah',
    'Jeremiah':             'Jeremiah',
    'Lamentations':         'Lamentations',
    'Ezekiel':              'Ezekiel',
    'Daniel':               'Daniel',
    'Hosea':                'Hosea',
    'Joel':                 'Joel',
    'Amos':                 'Amos',
    'Obadiah':              'Obadiah',
    'Jonah':                'Jonah',
    'Micah':                'Micah',
    'Nahum':                'Nahum',
    'Habakkuk':             'Habakkuk',
    'Zephaniah':            'Zephaniah',
    'Haggai':               'Haggai',
    'Zechariah':            'Zechariah',
    'Malachi':              'Malachi',
    # Standard NT (BSB)
    'Matthew':              'Matthew',
    'Mark':                 'Mark',
    'Luke':                 'Luke',
    'John':                 'John',
    'Acts':                 'Acts',
    'Romans':               'Romans',
    '1 Corinthians':        'I Corinthians',
    '2 Corinthians':        'II Corinthians',
    'Galatians':            'Galatians',
    'Ephesians':            'Ephesians',
    'Philippians':          'Philippians',
    'Colossians':           'Colossians',
    '1 Thessalonians':      'I Thessalonians',
    '2 Thessalonians':      'II Thessalonians',
    '1 Timothy':            'I Timothy',
    '2 Timothy':            'II Timothy',
    'Titus':                'Titus',
    'Philemon':             'Philemon',
    'Hebrews':              'Hebrews',
    'James':                'James',
    '1 Peter':              'I Peter',
    '2 Peter':              'II Peter',
    '1 John':               'I John',
    '2 John':               'II John',
    '3 John':               'III John',
    'Jude':                 'Jude',
    'Revelation':           'Revelation of John',
    # Deuterocanon (KJVA only)
    'Book of Tobit':        'Tobit',
    'Book of Judith':       'Judith',
    '1 Maccabees':          'I Maccabees',
    '2 Maccabees':          'II Maccabees',
    '3 Maccabees':          None,           # Not in KJVA
    'Wisdom of Solomon':    'Wisdom',
    'book of sirach':       'Sirach',
    'Baruch':               'Baruch',
    '3 Book of Ezra':       'I Esdras',     # KJVA I Esdras ≈ EOTC 3rd Ezra
    '2nd Book of Ezra':     'II Esdras',    # KJVA II Esdras ≈ EOTC Ezra Kale
    # Special: Letter of Jeremiah = Baruch ch6 in KJVA
    'Thr letter of Jeremiah': '__LETTER_OF_JER__',
    # R.H. Charles
    'Enoch':                '__CHARLES_ENOCH__',
    # No public-domain English source available
    'Jubilees':             None,
    'Teref Baruch':         None,
    'Book of Admonition':   None,
}

# ---------------------------------------------------------------------------
# R.H. Charles — Book of Enoch (Gutenberg #77935)
# Format: "CHAPTER_ROMAN. VERSE. text..." all on one block, wrapping lines.
# Pattern: "I. 1. The words..."  "II. 1. Observe ye..."
# Some chapters have no verse numbers: "III. Observe and see..."
# ---------------------------------------------------------------------------
ENOCH_URL = 'https://www.gutenberg.org/cache/epub/77935/pg77935.txt'


def fetch_url(url: str, cache_path: Path) -> str:
    if cache_path.exists():
        return cache_path.read_text(encoding='utf-8', errors='replace')
    print(f'  Fetching {cache_path.name} from {url[:60]}...')
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=30) as r:
            text = r.read().decode('utf-8', errors='replace')
        cache_path.write_text(text, encoding='utf-8')
        return text
    except Exception as e:
        print(f'  WARNING: Could not fetch: {e}')
        return ''


ROMAN_TO_INT = {}
def _build_roman():
    vals = [
        ('I',1),('II',2),('III',3),('IV',4),('V',5),('VI',6),('VII',7),
        ('VIII',8),('IX',9),('X',10),('XI',11),('XII',12),('XIII',13),
        ('XIV',14),('XV',15),('XVI',16),('XVII',17),('XVIII',18),('XIX',19),
        ('XX',20),('XXI',21),('XXII',22),('XXIII',23),('XXIV',24),('XXV',25),
        ('XXVI',26),('XXVII',27),('XXVIII',28),('XXIX',29),('XXX',30),
        ('XXXI',31),('XXXII',32),('XXXIII',33),('XXXIV',34),('XXXV',35),
        ('XXXVI',36),('XXXVII',37),('XXXVIII',38),('XXXIX',39),('XL',40),
        ('XLI',41),('XLII',42),('XLIII',43),('XLIV',44),('XLV',45),
        ('XLVI',46),('XLVII',47),('XLVIII',48),('XLIX',49),('L',50),
        ('LI',51),('LII',52),('LIII',53),('LIV',54),('LV',55),
        ('LVI',56),('LVII',57),('LVIII',58),('LIX',59),('LX',60),
        ('LXI',61),('LXII',62),('LXIII',63),('LXIV',64),('LXV',65),
        ('LXVI',66),('LXVII',67),('LXVIII',68),('LXIX',69),('LXX',70),
        ('LXXI',71),('LXXII',72),('LXXIII',73),('LXXIV',74),('LXXV',75),
        ('LXXVI',76),('LXXVII',77),('LXXVIII',78),('LXXIX',79),('LXXX',80),
        ('LXXXI',81),('LXXXII',82),('LXXXIII',83),('LXXXIV',84),('LXXXV',85),
        ('LXXXVI',86),('LXXXVII',87),('LXXXVIII',88),('LXXXIX',89),('XC',90),
        ('XCI',91),('XCII',92),('XCIII',93),('XCIV',94),('XCV',95),
        ('XCVI',96),('XCVII',97),('XCVIII',98),('XCIX',99),('C',100),
        ('CI',101),('CII',102),('CIII',103),('CIV',104),('CV',105),
        ('CVI',106),('CVII',107),('CVIII',108),
    ]
    for r, n in vals:
        ROMAN_TO_INT[r] = n

_build_roman()


def parse_enoch(text: str) -> dict[int, dict[int, str]]:
    """
    Parse Gutenberg R.H. Charles Enoch into {ch_int: {verse_int: text}}.

    The text format has lines like:
      "I. 1. The words of the blessing..."   — chapter I, verse 1
      "II. 1. Observe ye..."                 — chapter II, verse 1
      "III. Observe and see..."              — chapter III (no verse number → verse 1)

    Verses continue on subsequent lines until the next chapter/verse marker.
    """
    # Find start of actual text (after Gutenberg boilerplate)
    start_marker = '*** START OF THE PROJECT GUTENBERG EBOOK'
    idx = text.find(start_marker)
    if idx >= 0:
        text = text[idx:]

    # Pattern: "ROMAN. DIGIT. rest" or "ROMAN. rest" (chapter with no verse num)
    # ROMAN must be all caps roman numerals
    roman_pat = '|'.join(sorted(ROMAN_TO_INT.keys(), key=lambda x: -len(x)))
    ch_vs_pat = re.compile(
        rf'^({roman_pat})\.\s+(\d+)\.\s+(.*)',
        re.IGNORECASE
    )
    ch_only_pat = re.compile(
        rf'^({roman_pat})\.\s+([A-Z\[\(].+)',
        re.IGNORECASE
    )

    chapters: dict[int, dict[int, str]] = {}
    cur_ch: int | None = None
    cur_vs: int | None = None
    cur_text: list[str] = []

    def flush():
        if cur_ch is not None and cur_vs is not None and cur_text:
            t = ' '.join(cur_text).strip()
            # Remove editorial brackets/footnote markers but keep content
            t = re.sub(r'\s+', ' ', t)
            chapters.setdefault(cur_ch, {})[cur_vs] = t

    for line in text.splitlines():
        stripped = line.strip()
        if not stripped:
            continue
        # Skip section header lines (italic markers, footnotes)
        if stripped.startswith('_') or stripped.startswith('*'):
            continue

        m = ch_vs_pat.match(stripped)
        if m:
            flush()
            roman = m.group(1).upper()
            cur_ch = ROMAN_TO_INT.get(roman)
            cur_vs = int(m.group(2))
            cur_text = [m.group(3).strip()]
            continue

        m2 = ch_only_pat.match(stripped)
        if m2:
            flush()
            roman = m2.group(1).upper()
            cur_ch = ROMAN_TO_INT.get(roman)
            cur_vs = 1
            cur_text = [m2.group(2).strip()]
            continue

        # Continuation line
        if cur_ch is not None:
            # Check if this line starts a new verse (digit. text) within current chapter
            vs_cont = re.match(r'^(\d+)\.\s+(.*)', stripped)
            if vs_cont and not re.match(roman_pat + r'\.', stripped, re.IGNORECASE):
                flush()
                cur_vs = int(vs_cont.group(1))
                cur_text = [vs_cont.group(2).strip()]
                continue
            cur_text.append(stripped)

    flush()
    return chapters


def build_charles_chapters(
    charles_map: dict[int, dict[int, str]],
    am_chapters: list,
) -> list:
    """Build EN chapter list from Charles parsed data, aligned to Amharic chapters."""
    result = []
    for ch_data in am_chapters:
        ch_num = ch_data['chapter']
        vs_map = charles_map.get(ch_num, {})
        if vs_map:
            verses = [{'verse': vn, 'text': vt} for vn, vt in sorted(vs_map.items())]
            result.append({'chapter': ch_num, 'sections': [{'title': '', 'verses': verses}]})
        else:
            # Placeholder for missing chapter
            placeholder_verses = [
                {'verse': v['verse'], 'text': '[English text not available]'}
                for sec in ch_data['sections'] for v in sec['verses']
            ]
            result.append({'chapter': ch_num, 'sections': [{'title': '', 'verses': placeholder_verses}]})
    return result


# ---------------------------------------------------------------------------
# Load source Bibles
# ---------------------------------------------------------------------------
def load_scrollmapper(path: Path) -> dict[str, list]:
    """Returns {book_name: chapters_list}"""
    with open(path, encoding='utf-8') as f:
        data = json.load(f)
    return {b['name']: b['chapters'] for b in data['books']}


print('Loading BSB...')
bsb = load_scrollmapper(BSB_PATH)
print(f'  {len(bsb)} books')

print('Loading KJVA...')
kjva = load_scrollmapper(KJVA_PATH)
print(f'  {len(kjva)} books')

print('Fetching R.H. Charles - Book of Enoch...')
enoch_text = fetch_url(ENOCH_URL, CHARLES_CACHE / 'Enoch.txt')
enoch_data = parse_enoch(enoch_text) if enoch_text else {}
print(f'  Enoch: {len(enoch_data)} chapters parsed')

# ---------------------------------------------------------------------------
# Helper: build chapter from scrollmapper chapter list
# ---------------------------------------------------------------------------
def build_scroll_chapter(scroll_chapters: list, ch_num: int) -> dict | None:
    for ch in scroll_chapters:
        if ch.get('chapter') == ch_num:
            verses = [
                {'verse': v['verse'], 'text': v['text'].strip()}
                for v in ch.get('verses', [])
                if v.get('text', '').strip()
            ]
            if verses:
                return {'chapter': ch_num, 'sections': [{'title': '', 'verses': verses}]}
    return None


def build_scroll_chapters(scroll_chs: list, am_chapters: list, source: str, book_en: str,
                          mismatches: list, partial: list) -> list:
    result = []
    scroll_ch_count = len(scroll_chs)
    am_ch_count = len(am_chapters)

    if scroll_ch_count != am_ch_count:
        mismatches.append(
            f'{book_en}: EOTC={am_ch_count} chapters, {source}={scroll_ch_count} chapters'
        )

    for ch_data in am_chapters:
        ch_num = ch_data['chapter']
        ch_out = build_scroll_chapter(scroll_chs, ch_num)
        if ch_out:
            am_v = sum(len(s['verses']) for s in ch_data['sections'])
            en_v = len(ch_out['sections'][0]['verses'])
            if abs(am_v - en_v) > 3:
                mismatches.append(
                    f'{book_en} ch{ch_num}: EOTC={am_v}v, {source}={en_v}v'
                )
            result.append(ch_out)
        else:
            partial.append(f'{book_en} ch{ch_num} missing in {source}')
            placeholder = [
                {'verse': v['verse'], 'text': '[English text not available]'}
                for sec in ch_data['sections'] for v in sec['verses']
            ]
            result.append({'chapter': ch_num, 'sections': [{'title': '', 'verses': placeholder}]})
    return result


def placeholder_chapters(am_chapters: list) -> list:
    result = []
    for ch_data in am_chapters:
        placeholder = [
            {'verse': v['verse'], 'text': '[English text not available]'}
            for sec in ch_data['sections'] for v in sec['verses']
        ]
        result.append({'chapter': ch_data['chapter'], 'sections': [{'title': '', 'verses': placeholder}]})
    return result


# ---------------------------------------------------------------------------
# Special: Letter of Jeremiah = Baruch chapter 6 in KJVA, renumbered as ch 1
# ---------------------------------------------------------------------------
def build_letter_of_jer(am_chapters: list) -> list | None:
    baruch_chs = kjva.get('Baruch')
    if not baruch_chs:
        return None
    ch6 = build_scroll_chapter(baruch_chs, 6)
    if not ch6:
        return None
    ch6['chapter'] = 1
    return [ch6]


# ---------------------------------------------------------------------------
# Psalms: LXX (EOTC/Amharic) → Masoretic (BSB/KJVA) chapter mapping
#
# Key divergences:
#   LXX 9        = MT 9+10 merged   (LXX has them as one 38-verse psalm)
#   LXX 10–112   = MT 11–113        (shift of 1)
#   LXX 113      = MT 114+115 merged
#   LXX 114      = MT 116:1–9       (split: first half)
#   LXX 115      = MT 116:10–19     (split: second half)
#   LXX 116–145  = MT 117–146       (shift of 1 again)
#   LXX 146      = MT 147:1–11      (split)
#   LXX 147      = MT 147:12–20     (split)
#   LXX 148–150  = MT 148–150       (same)
#   LXX 151      = EOTC only (no MT equivalent)
#
# For splits: we combine both MT halves into one chapter.
# For merges: the LXX chapter is already the combined text in Amharic,
#   so we combine both MT chapters for the English output.
# ---------------------------------------------------------------------------

def build_psalms_en(bsb_psalms_chs: list, am_chapters: list,
                    mismatches: list, partial: list) -> list:
    """Build English Psalms aligned to LXX chapter numbering."""
    # Index BSB chapters by number for fast lookup
    mt: dict[int, list] = {}  # {mt_ch: [verse_dicts]}
    for ch in bsb_psalms_chs:
        mt[ch['chapter']] = [
            {'verse': v['verse'], 'text': v['text'].strip()}
            for v in ch['verses'] if v.get('text', '').strip()
        ]

    def merged_verses(mt_chs: list[int]) -> list:
        """Concatenate verses from multiple MT chapters, renumbering sequentially."""
        all_verses = []
        seq = 1
        for mt_ch in mt_chs:
            for v in mt.get(mt_ch, []):
                all_verses.append({'verse': seq, 'text': v['text']})
                seq += 1
        return all_verses

    def split_verses(mt_ch: int, start: int, end: int | None) -> list:
        """Take a slice of an MT chapter's verses (1-indexed, inclusive)."""
        vs = mt.get(mt_ch, [])
        sliced = vs[start - 1 : end]  # end=None takes to end of list
        return [{'verse': i + 1, 'text': v['text']} for i, v in enumerate(sliced)]

    result = []
    for ch_data in am_chapters:
        lxx = ch_data['chapter']
        verses: list = []

        if lxx == 9:
            # LXX 9 = MT 9 + MT 10 combined
            verses = merged_verses([9, 10])
        elif 10 <= lxx <= 112:
            # LXX 10–112 → MT 11–113 (shift +1)
            verses = [{'verse': v['verse'], 'text': v['text']} for v in mt.get(lxx + 1, [])]
        elif lxx == 113:
            # LXX 113 = MT 114 + MT 115 combined
            verses = merged_verses([114, 115])
        elif lxx == 114:
            # LXX 114 = MT 116 verses 1–9
            verses = split_verses(116, 1, 9)
        elif lxx == 115:
            # LXX 115 = MT 116 verses 10–19
            verses = split_verses(116, 10, None)
        elif 116 <= lxx <= 145:
            # LXX 116–145 → MT 117–146 (shift +1)
            verses = [{'verse': v['verse'], 'text': v['text']} for v in mt.get(lxx + 1, [])]
        elif lxx == 146:
            # LXX 146 = MT 147 verses 1–11
            verses = split_verses(147, 1, 11)
        elif lxx == 147:
            # LXX 147 = MT 147 verses 12–20
            verses = split_verses(147, 12, None)
        elif 148 <= lxx <= 150:
            # LXX 148–150 = MT 148–150 (same)
            verses = [{'verse': v['verse'], 'text': v['text']} for v in mt.get(lxx, [])]
        elif lxx == 151:
            # EOTC only — no MT equivalent, use placeholder
            verses = [
                {'verse': v['verse'], 'text': '[Psalm 151 — EOTC only, no standard English translation]'}
                for sec in ch_data['sections'] for v in sec['verses']
            ]
        else:
            # 1–8: same in both
            verses = [{'verse': v['verse'], 'text': v['text']} for v in mt.get(lxx, [])]

        if not verses:
            partial.append(f'Psalms ch{lxx} (MT lookup) produced no verses')
            verses = [
                {'verse': v['verse'], 'text': '[English text not available]'}
                for sec in ch_data['sections'] for v in sec['verses']
            ]

        result.append({'chapter': lxx, 'sections': [{'title': '', 'verses': verses}]})

    return result


# ---------------------------------------------------------------------------
# Daniel: LXX additions
#
# EOTC Daniel follows the LXX (Greek) canon which includes three additions
# not in the Hebrew/BSB:
#   ch3  (97v): BSB ch3 (30v) + "Prayer of Azariah" from KJVA (68v) appended
#   ch13 (64v): KJVA "Susanna" (64v, ch1)
#   ch14 (42v): KJVA "Bel and the Dragon" (42v, ch1)
#   ch1-12, ch4-12: straight from BSB (same as MT)
# ---------------------------------------------------------------------------

def build_daniel_en(bsb_daniel_chs: list, am_chapters: list,
                    mismatches: list, partial: list) -> list:
    # Index BSB chapters
    bsb_ch = {c['chapter']: c['verses'] for c in bsb_daniel_chs}

    # KJVA additions
    prayer_az = kjva.get('Prayer of Azariah', [{}])[0].get('verses', [])
    susanna   = kjva.get('Susanna',           [{}])[0].get('verses', [])
    bel_drag  = kjva.get('Bel and the Dragon',[{}])[0].get('verses', [])

    result = []
    for ch_data in am_chapters:
        n = ch_data['chapter']
        am_vc = sum(len(s['verses']) for s in ch_data['sections'])

        if n == 3:
            # Combine BSB ch3 + Prayer of Azariah, renumber sequentially
            base = [{'verse': v['verse'], 'text': v['text'].strip()}
                    for v in bsb_ch.get(3, [])]
            addition = [{'verse': len(base) + i + 1, 'text': v['text'].strip()}
                        for i, v in enumerate(prayer_az)]
            verses = base + addition
        elif n == 13:
            verses = [{'verse': v['verse'], 'text': v['text'].strip()} for v in susanna]
        elif n == 14:
            verses = [{'verse': v['verse'], 'text': v['text'].strip()} for v in bel_drag]
        else:
            raw = bsb_ch.get(n, [])
            verses = [{'verse': v['verse'], 'text': v['text'].strip()} for v in raw]
            if not verses:
                partial.append(f'Daniel ch{n} missing in BSB')
                verses = [
                    {'verse': v['verse'], 'text': '[English text not available]'}
                    for sec in ch_data['sections'] for v in sec['verses']
                ]

        # Flag large mismatches (tolerance 5 for ch3 which we're combining)
        tol = 5 if n == 3 else 3
        if abs(len(verses) - am_vc) > tol:
            mismatches.append(
                f'Daniel ch{n}: EOTC={am_vc}v, EN={len(verses)}v'
            )

        result.append({'chapter': n, 'sections': [{'title': '', 'verses': verses}]})

    return result


# ---------------------------------------------------------------------------
# Main conversion loop
# ---------------------------------------------------------------------------
am_files = sorted(AM_DIR.glob('*.json'))
stats: dict[str, list] = {'bsb': [], 'kjva': [], 'charles': [], 'placeholder': []}
mismatches: list[str] = []
partial: list[str] = []

for am_path in am_files:
    with open(am_path, encoding='utf-8') as f:
        am = json.load(f)

    book_en       = am['book_name_en']
    am_chapters   = am['chapters']
    filename      = am_path.name
    scroll_key    = EOTC_TO_SCROLL.get(book_en, 'UNKNOWN')

    en_chapters: list = []
    source_label = 'placeholder'

    if scroll_key == '__CHARLES_ENOCH__':
        if enoch_data:
            en_chapters = build_charles_chapters(enoch_data, am_chapters)
            source_label = 'charles'
        else:
            en_chapters = placeholder_chapters(am_chapters)

    elif scroll_key == '__LETTER_OF_JER__':
        result = build_letter_of_jer(am_chapters)
        if result:
            en_chapters = result
            source_label = 'kjva'
        else:
            en_chapters = placeholder_chapters(am_chapters)

    elif scroll_key is None or scroll_key == 'UNKNOWN':
        en_chapters = placeholder_chapters(am_chapters)

    else:
        # Try BSB first (standard canon), then KJVA (deuterocanon)
        if scroll_key in bsb:
            if book_en == 'Psalms':
                # Use LXX→MT aware mapper instead of naive chapter-by-number lookup
                en_chapters = build_psalms_en(bsb[scroll_key], am_chapters, mismatches, partial)
            elif book_en == 'Daniel':
                # EOTC Daniel has 14 chapters; BSB only has 12.
                # ch3: EOTC (97v) = BSB ch3 (30v) + KJVA "Prayer of Azariah" (68v)
                # ch13: EOTC (64v) = KJVA "Susanna" (64v)
                # ch14: EOTC (42v) = KJVA "Bel and the Dragon" (42v)
                en_chapters = build_daniel_en(bsb[scroll_key], am_chapters, mismatches, partial)
            else:
                en_chapters = build_scroll_chapters(
                    bsb[scroll_key], am_chapters, 'BSB', book_en, mismatches, partial
                )
            source_label = 'bsb'
        elif scroll_key in kjva:
            en_chapters = build_scroll_chapters(
                kjva[scroll_key], am_chapters, 'KJVA', book_en, mismatches, partial
            )
            source_label = 'kjva'
        else:
            en_chapters = placeholder_chapters(am_chapters)

    stats[source_label].append(book_en)

    out = {
        'book_number':        am['book_number'],
        'book_name_am':       am['book_name_am'],
        'book_short_name_am': am['book_short_name_am'],
        'book_name_en':       book_en,
        'book_short_name_en': am['book_short_name_en'],
        'testament':          am['testament'],
        'chapters':           en_chapters,
    }

    out_path = EN_DIR / filename
    with open(out_path, 'w', encoding='utf-8') as f:
        json.dump(out, f, ensure_ascii=False, indent=2)

    am_ch = len(am_chapters)
    en_ch = len(en_chapters)
    ch_note = f'{en_ch}/{am_ch} ch' + (' MISMATCH' if en_ch != am_ch else '')
    print(f'  [{source_label:11s}] {am["book_number"]:2d}. {book_en} ({ch_note})')

# ---------------------------------------------------------------------------
# Coverage report
# ---------------------------------------------------------------------------
total_real = len(stats['bsb']) + len(stats['kjva']) + len(stats['charles'])
total_books = len(am_files)

print()
print('=' * 70)
print('COVERAGE REPORT')
print('=' * 70)
print(f'BSB (Berean Standard Bible):    {len(stats["bsb"])} books')
print(f'KJVA (KJV + Apocrypha):         {len(stats["kjva"])} books')
print(f'R.H. Charles:                   {len(stats["charles"])} books')
print(f'Placeholder only:               {len(stats["placeholder"])} books')
print(f'  {", ".join(stats["placeholder"]) or "none"}')
print()
print(f'Real English text:  {total_real}/{total_books} books')
print(f'Placeholders:       {len(stats["placeholder"])}/{total_books} books')

if mismatches:
    print(f'\nMISMATCHES / WARNINGS ({len(mismatches)}):')
    for m in mismatches:
        print(f'  ! {m}')

if partial:
    print(f'\nPARTIAL CHAPTERS (missing from source) ({len(partial)}):')
    for p in partial:
        print(f'  ! {p}')

print()
print(f'Output: {EN_DIR}')
print('Done.')
