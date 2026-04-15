from __future__ import annotations

import hashlib
import json
import os
import re
import shutil
from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
SOURCE_ROOT = REPO_ROOT / "assets" / "mezmuer" / "best mezmure"
LIBRARY_ROOT = REPO_ROOT / "assets" / "mezmuer" / "library"
ARTISTS_ROOT = LIBRARY_ROOT / "artists"
COMPILATIONS_ROOT = LIBRARY_ROOT / "compilations"
MANIFEST_PATH = REPO_ROOT / "assets" / "data" / "mezmur_library.json"
FFMPEG_CACHE_ROOT = REPO_ROOT / "tools" / ".cache" / "ffmpeg"
JUNK_NAMES = {
    "desktop.ini",
    "folder.jpg",
    "thumbs.db",
    "bbthumbs.dat",
    "albumartsmall.jpg",
}
SUPPORTED_AUDIO_EXTENSIONS = {".mp3", ".wma"}


@dataclass(frozen=True)
class TopLevelSpec:
    kind: str
    slug: str
    display: str
    artist_slug: str | None = None
    artist_display: str | None = None
    volume_number: int | None = None
    preserve_as_compilation: bool = False


@dataclass(frozen=True)
class AlbumUnit:
    source_dir: Path
    album_slug: str
    album_display: str
    album_number: int | None


COMPILATION_SPECS: dict[str, TopLevelSpec] = {
    "6 በአንድ": TopLevelSpec("compilation", "six-in-one", "Six In One"),
    "7ቱ ዘማርያን": TopLevelSpec("compilation", "seven-singers", "Seven Singers"),
    "8 በአንድ": TopLevelSpec("compilation", "eight-in-one", "Eight In One"),
    "8ቱ ዘማርያን": TopLevelSpec("compilation", "eight-singers", "Eight Singers"),
    "ገጹ እሳተ ልብሱ እሳት": TopLevelSpec(
        "compilation",
        "gezu-esate-libsu-esat-eight-in-one",
        "Gezu Esate Libsu Esat Eight In One",
        preserve_as_compilation=True,
    ),
}

ARTIST_VOLUME_SPECS: dict[str, TopLevelSpec] = {
    "zeben 4": TopLevelSpec(
        "artist-volume",
        "zeben",
        "Zeben",
        artist_slug="zeben",
        artist_display="Zeben",
        volume_number=4,
    ),
    "ሳራ 4": TopLevelSpec(
        "artist-volume",
        "sara",
        "Sara",
        artist_slug="sara",
        artist_display="Sara",
        volume_number=4,
    ),
    "እንግዳ ወርቅ 10": TopLevelSpec(
        "artist-volume",
        "engedawork",
        "Engedawork",
        artist_slug="engedawork",
        artist_display="Engedawork",
        volume_number=10,
    ),
    "ፍቅረ ማሪያም 5": TopLevelSpec(
        "artist-volume",
        "fikre-mariam",
        "Fikre Mariam",
        artist_slug="fikre-mariam",
        artist_display="Fikre Mariam",
        volume_number=5,
    ),
}

ARTIST_SPECS: dict[str, TopLevelSpec] = {
    "bertukan": TopLevelSpec("artist", "bertukan", "Bertukan"),
    "g yohanes": TopLevelSpec("artist", "g-yohanes", "G Yohanes"),
    "Heywote": TopLevelSpec("artist", "heywote", "Heywote"),
    "mendayae": TopLevelSpec("artist", "mendayae", "Mendayae"),
    "shemales": TopLevelSpec("artist", "shemales", "Shemales"),
    "ሀብታሙ": TopLevelSpec("artist", "habtamu", "Habtamu"),
    "ህጸን አንቁ": TopLevelSpec("artist", "hitsen-anqu", "Hitsen Anqu"),
    "ልአል ሰገድ": TopLevelSpec("artist", "luel-seged", "Luel Seged"),
    "መቅደስ": TopLevelSpec("artist", "mekdes", "Mekdes"),
    "ማርታ": TopLevelSpec("artist", "marta", "Marta"),
    "ምርትነሽ": TopLevelSpec("artist", "mirtnesh", "Mirtnesh"),
    "ሰላማዊት": TopLevelSpec("artist", "selamawit", "Selamawit"),
    "ስንድ": TopLevelSpec("artist", "sind", "Sind"),
    "ሶሊያና": TopLevelSpec("artist", "solyana", "Solyana"),
    "ቅድስት": TopLevelSpec("artist", "kidist", "Kidist"),
    "በህይሉ": TopLevelSpec("artist", "behiylu", "Behiylu"),
    "ታምራት": TopLevelSpec("artist", "tamirat", "Tamirat"),
    "ታዲዮስ": TopLevelSpec("artist", "tadios", "Tadios"),
    "ቴድሮስ": TopLevelSpec("artist", "tedros", "Tedros"),
    "ቸርነት": TopLevelSpec("artist", "chirnet", "Chirnet"),
    "አልተሳሳትንም": TopLevelSpec("artist", "altesasatnem", "Altesasatnem"),
    "አስጢፋኖስ": TopLevelSpec("artist", "estifanos", "Estifanos"),
    "አርሚያስ": TopLevelSpec("artist", "armiyas", "Armiyas"),
    "አሸናፊ": TopLevelSpec("artist", "ashenafi", "Ashenafi"),
    "አንዳልካቸው": TopLevelSpec("artist", "andalkachew", "Andalkachew"),
    "አዲስ": TopLevelSpec("artist", "adis", "Adis"),
    "ዘለሰኛ": TopLevelSpec("artist", "zelesegna", "Zelesegna"),
    "ይልማ": TopLevelSpec("artist", "yilma", "Yilma"),
    "ዳግማዊ": TopLevelSpec("artist", "dagmawi", "Dagmawi"),
    "ጌልቦአ": TopLevelSpec("artist", "gelboa", "Gelboa"),
    "ፀዳለ": TopLevelSpec("artist", "tsedale", "Tsedale"),
    "ጽጌረዳ": TopLevelSpec("artist", "tsegereda", "Tsegereda"),
    "ፉንቱ ወልዴ": TopLevelSpec("artist", "funtu-welde", "Funtu Welde"),
}

ARTIST_ALIASES: dict[str, tuple[str, ...]] = {
    "bertukan": ("bertukan",),
    "g-yohanes": ("g yohanes",),
    "heywote": ("heywote",),
    "mendayae": ("mendayae",),
    "shemales": ("shemales", "shmeles"),
    "habtamu": ("habtamu", "unknown artist unknown album"),
    "hitsen-anqu": ("hitsen anqu",),
    "luel-seged": ("luleseghed", "luel seged"),
    "mekdes": ("meke", "mekdes"),
    "marta": ("marta",),
    "mirtnesh": ("mez", "mirtnesh"),
    "selamawit": ("selam", "selam mezmur", "selamawit"),
    "sind": ("senu", "sind"),
    "solyana": ("solyana",),
    "kidist": ("kedest", "kidist"),
    "behiylu": ("behiylu",),
    "tamirat": ("tamerat", "tamirat"),
    "tadios": ("tadios",),
    "tedros": ("tedros", "teddy", "tedy", "tedi"),
    "chirnet": ("chirnet",),
    "altesasatnem": ("altesasatnem",),
    "estifanos": ("estifanos",),
    "armiyas": ("armiyas",),
    "ashenafi": ("ashenafi",),
    "andalkachew": ("andalkachew",),
    "adis": ("adis", "new collection a"),
    "engedawork": ("engedawork",),
    "zelesegna": ("zelesegna",),
    "yilma": ("yilma", "yelema", "yelma"),
    "dagmawi": ("dagmawi",),
    "gelboa": ("gelboa",),
    "tsedale": ("tsedale",),
    "tsegereda": ("tsegireda", "tsegereda"),
    "funtu-welde": ("funtu welde",),
    "zeben": ("zeben",),
    "sara": ("sara",),
    "fikre-mariam": ("fikre mariam",),
}

GENERIC_BASES = {
    "artist",
    "track",
    "new",
    "mez",
    "senu",
    "kedest",
    "solyana",
    "teddy",
    "tamerat",
    "marta",
    "shmeles",
    "altesasatnem",
    "tsegireda",
    "tsedale",
    "engedawork",
    "luleseghed",
    "meke",
    "yilma",
}


def main() -> int:
    if not SOURCE_ROOT.exists():
        raise SystemExit(f"Source folder not found: {SOURCE_ROOT}")

    if LIBRARY_ROOT.exists():
        shutil.rmtree(LIBRARY_ROOT)
    LIBRARY_ROOT.mkdir(parents=True, exist_ok=True)
    ARTISTS_ROOT.mkdir(parents=True, exist_ok=True)
    COMPILATIONS_ROOT.mkdir(parents=True, exist_ok=True)

    ffmpeg_path = ensure_ffmpeg()
    manifest_entries: list[dict[str, object]] = []

    for folder in sorted(SOURCE_ROOT.iterdir(), key=lambda path: path.name.lower()):
        if not folder.is_dir():
            continue
        spec = resolve_spec(folder.name)
        if spec.kind == "compilation":
            manifest_entries.extend(process_compilation_folder(folder, spec, ffmpeg_path))
            continue
        if spec.kind == "artist-volume":
            manifest_entries.extend(process_artist_volume_folder(folder, spec, ffmpeg_path))
            continue
        manifest_entries.extend(process_artist_folder(folder, spec, ffmpeg_path))

    manifest_entries.sort(
        key=lambda item: (
            str(item["artist"]).lower(),
            str(item["album"]).lower(),
            int(item["trackNumber"]),
            str(item["title"]).lower(),
        )
    )
    MANIFEST_PATH.parent.mkdir(parents=True, exist_ok=True)
    MANIFEST_PATH.write_text(
        json.dumps({"tracks": manifest_entries}, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    print(f"Generated {len(manifest_entries)} tracks into {LIBRARY_ROOT}")
    print(f"Wrote manifest: {MANIFEST_PATH}")
    return 0


def resolve_spec(folder_name: str) -> TopLevelSpec:
    if folder_name in COMPILATION_SPECS:
        return COMPILATION_SPECS[folder_name]
    if folder_name in ARTIST_VOLUME_SPECS:
        return ARTIST_VOLUME_SPECS[folder_name]
    if folder_name in ARTIST_SPECS:
        return ARTIST_SPECS[folder_name]
    raise KeyError(f"No cleanup spec defined for {folder_name!r}")


def process_compilation_folder(
    folder: Path,
    spec: TopLevelSpec,
    ffmpeg_path: Path,
) -> list[dict[str, object]]:
    album_units = discover_album_units(folder, default_album_number=1)
    if not album_units:
        album_units = [AlbumUnit(folder, spec.slug, spec.display, 1)]

    manifest_entries: list[dict[str, object]] = []
    for index, unit in enumerate(album_units, start=1):
        compilation_slug = spec.slug
        compilation_display = spec.display
        if len(album_units) > 1:
            compilation_slug = f"{spec.slug}-set-{index:02d}"
            compilation_display = f"{spec.display} Set {index}"
        destination_dir = COMPILATIONS_ROOT / compilation_slug
        manifest_entries.extend(
            materialize_album(
                unit.source_dir,
                destination_dir,
                artist=compilation_display,
                artist_slug=compilation_slug,
                album=compilation_display,
                album_slug=compilation_slug,
                is_compilation=True,
                ffmpeg_path=ffmpeg_path,
                original_folder_name=folder.name,
            )
        )
    return manifest_entries


def process_artist_volume_folder(
    folder: Path,
    spec: TopLevelSpec,
    ffmpeg_path: Path,
) -> list[dict[str, object]]:
    artist_root = ARTISTS_ROOT / spec.artist_slug
    album_slug = volume_slug(spec.volume_number or 1)
    album_display = volume_display(spec.volume_number or 1)
    destination_dir = artist_root / album_slug
    return materialize_album(
        folder,
        destination_dir,
        artist=spec.artist_display or spec.display,
        artist_slug=spec.artist_slug or spec.slug,
        album=album_display,
        album_slug=album_slug,
        is_compilation=False,
        ffmpeg_path=ffmpeg_path,
        original_folder_name=folder.name,
    )


def process_artist_folder(
    folder: Path,
    spec: TopLevelSpec,
    ffmpeg_path: Path,
) -> list[dict[str, object]]:
    artist_root = ARTISTS_ROOT / spec.slug
    album_units = discover_album_units(folder, default_album_number=1)
    if not album_units:
        album_units = [AlbumUnit(folder, volume_slug(1), volume_display(1), 1)]

    slug_counts: dict[str, int] = defaultdict(int)
    manifest_entries: list[dict[str, object]] = []
    for unit in album_units:
        slug_counts[unit.album_slug] += 1
        occurrence = slug_counts[unit.album_slug]
        album_slug = unit.album_slug
        album_display = unit.album_display
        if occurrence > 1:
            album_slug = f"{album_slug}-set-{occurrence:02d}"
            album_display = f"{album_display} Set {occurrence}"
        destination_dir = artist_root / album_slug
        manifest_entries.extend(
            materialize_album(
                unit.source_dir,
                destination_dir,
                artist=spec.display,
                artist_slug=spec.slug,
                album=album_display,
                album_slug=album_slug,
                is_compilation=False,
                ffmpeg_path=ffmpeg_path,
                original_folder_name=folder.name,
            )
        )
    return manifest_entries


def discover_album_units(folder: Path, default_album_number: int) -> list[AlbumUnit]:
    audio_files_in_root = list_audio_files(folder)
    units: list[AlbumUnit] = []
    used_numbers: set[int] = set()
    if audio_files_in_root:
        root_number = extract_volume_number(folder.name) or default_album_number
        used_numbers.add(root_number)
        units.append(
            AlbumUnit(
                folder,
                volume_slug(root_number),
                volume_display(root_number),
                root_number,
            )
        )

    numbered_subdirs: list[tuple[Path, int]] = []
    unnumbered_subdirs: list[Path] = []
    for subdir in sorted((path for path in folder.iterdir() if path.is_dir()), key=lambda path: path.name.lower()):
        nested_audio = list_audio_files(subdir)
        if not nested_audio:
            continue
        number = extract_volume_number(subdir.name)
        if number is None:
            unnumbered_subdirs.append(subdir)
            continue
        numbered_subdirs.append((subdir, number))

    for subdir, number in numbered_subdirs:
        used_numbers.add(number)
        units.append(
            AlbumUnit(
                subdir,
                volume_slug(number),
                volume_display(number),
                number,
            )
        )

    for subdir in unnumbered_subdirs:
        base_number = extract_volume_number(folder.name) or default_album_number
        number = next_available_volume_number(used_numbers, base_number)
        used_numbers.add(number)
        units.append(
            AlbumUnit(
                subdir,
                volume_slug(number),
                volume_display(number),
                number,
            )
        )
    return units


def materialize_album(
    source_dir: Path,
    destination_dir: Path,
    *,
    artist: str,
    artist_slug: str,
    album: str,
    album_slug: str,
    is_compilation: bool,
    ffmpeg_path: Path,
    original_folder_name: str,
) -> list[dict[str, object]]:
    audio_files = sorted(list_audio_files(source_dir), key=sort_key_for_track)
    destination_dir.mkdir(parents=True, exist_ok=True)
    manifest_entries: list[dict[str, object]] = []
    seen_output_names: set[str] = set()

    for sequence_index, source_file in enumerate(audio_files, start=1):
        track_number = extract_track_number(source_file.name) or sequence_index
        title = normalize_track_title(source_file, artist_slug, track_number)
        output_filename = f"{track_number:02d} - {title}.mp3"
        if output_filename in seen_output_names:
            continue
        seen_output_names.add(output_filename)
        destination_file = destination_dir / output_filename
        if source_file.suffix.lower() == ".wma":
            convert_to_mp3(ffmpeg_path, source_file, destination_file)
        else:
            shutil.copy2(source_file, destination_file)

        relative_path = destination_file.relative_to(REPO_ROOT).as_posix()
        manifest_entries.append(
            {
                "id": stable_track_id(relative_path),
                "title": title,
                "artist": artist,
                "album": album,
                "trackNumber": track_number,
                "assetPath": relative_path,
                "format": "mp3",
                "isCompilation": is_compilation,
                "searchText": build_search_text(
                    title=title,
                    artist=artist,
                    album=album,
                    original_folder_name=original_folder_name,
                    original_file_name=source_file.stem,
                ),
            }
        )
    return manifest_entries


def list_audio_files(folder: Path) -> list[Path]:
    return [
        path
        for path in folder.iterdir()
        if path.is_file()
        and path.suffix.lower() in SUPPORTED_AUDIO_EXTENSIONS
        and not is_junk_file(path.name)
    ]


def is_junk_file(filename: str) -> bool:
    lower_name = filename.lower()
    if lower_name in JUNK_NAMES:
        return True
    return lower_name.startswith("albumart") or lower_name.startswith("folderhighlight")


def sort_key_for_track(path: Path) -> tuple[int, str]:
    number = extract_track_number(path.name) or 999
    return (number, path.name.lower())


def extract_volume_number(text: str) -> int | None:
    match = re.search(r"(\d+)", text)
    if not match:
        return None
    return int(match.group(1))


def extract_track_number(filename: str) -> int | None:
    stem = Path(filename).stem
    match = re.match(r"^\s*(\d{1,3})", stem)
    if match:
        return int(match.group(1))
    match = re.search(r"\((\d{1,3})\)\s*$", stem)
    if match:
        return int(match.group(1))
    match = re.search(r"track\s*([0-9]{1,3})", stem, re.IGNORECASE)
    if match:
        return int(match.group(1))
    return None


def normalize_track_title(path: Path, artist_slug: str, track_number: int) -> str:
    stem = path.stem
    normalized = stem.replace("_", " ").replace("%20", " ")
    normalized = re.sub(r"\bunknown artist unknown album\b", "", normalized, flags=re.IGNORECASE)
    normalized = re.sub(r"^\s*\d{1,3}[\)\]._-]*\s*", "", normalized)
    normalized = re.sub(r"\((\d{1,3})\)\s*$", "", normalized).strip()
    normalized = normalized.replace("â€¢", " ")
    normalized = normalized.replace("  ", " ")
    normalized = remove_artist_aliases(normalized, artist_slug)
    normalized = re.sub(r"^(track|trac\w*|artist)\b", "", normalized, flags=re.IGNORECASE).strip()
    normalized = re.sub(r"\b(track|trac\w*|artist)\b", " ", normalized, flags=re.IGNORECASE)
    normalized = re.sub(r"[\(\)\[\]\{\}]", " ", normalized)
    normalized = re.sub(r"[-–_]+", " ", normalized)
    normalized = re.sub(r"\s+", " ", normalized).strip(" .")

    if not normalized:
        return f"Track {track_number:02d}"

    if contains_ethiopic(normalized):
        return f"Track {track_number:02d}"

    lowered = normalized.lower()
    if lowered in GENERIC_BASES or lowered == "in one" or re.fullmatch(r"[a-z]{0,4}\d*", lowered):
        return f"Track {track_number:02d}"
    if re.fullmatch(r"\d{1,3}", lowered):
        return f"Track {track_number:02d}"

    normalized = re.sub(r"\b0+(\d)\b", r"\1", normalized)
    normalized = normalized.strip()
    if not normalized:
        return f"Track {track_number:02d}"
    return title_case_preserving_numbers(normalized)


def remove_artist_aliases(text: str, artist_slug: str) -> str:
    result = text
    for alias in ARTIST_ALIASES.get(artist_slug, ()):
        pattern = re.compile(rf"^\s*{re.escape(alias)}\s*[-:]*\s*", re.IGNORECASE)
        result = pattern.sub("", result).strip()
    return result


def contains_ethiopic(text: str) -> bool:
    return any("\u1200" <= char <= "\u137f" for char in text)


def title_case_preserving_numbers(text: str) -> str:
    words = []
    for token in text.split():
        if token.isupper() and len(token) <= 4:
            words.append(token)
            continue
        words.append(token[:1].upper() + token[1:].lower())
    return " ".join(words)


def build_search_text(
    *,
    title: str,
    artist: str,
    album: str,
    original_folder_name: str,
    original_file_name: str,
) -> str:
    parts = [title, artist, album, original_folder_name, original_file_name]
    merged = " ".join(parts)
    return re.sub(r"\s+", " ", merged).strip().lower()


def stable_track_id(relative_path: str) -> str:
    digest = hashlib.sha1(relative_path.encode("utf-8")).hexdigest()[:12]
    return f"mezmur-{digest}"


def volume_slug(number: int) -> str:
    return f"vol-{number:02d}"


def volume_display(number: int) -> str:
    return f"Vol {number:02d}"


def next_available_volume_number(used_numbers: set[int], base_number: int) -> int:
    candidate = max(used_numbers, default=base_number - 1) + 1
    while candidate in used_numbers:
        candidate += 1
    return candidate


def ensure_ffmpeg() -> Path:
    import subprocess

    candidates: list[Path] = []
    path_candidate = shutil.which("ffmpeg")
    if path_candidate:
        candidates.append(Path(path_candidate))

    local_app_data = os.environ.get("LOCALAPPDATA")
    if local_app_data:
        winget_root = Path(local_app_data) / "Microsoft" / "WinGet" / "Packages"
        if winget_root.exists():
            candidates.extend(winget_root.rglob("ffmpeg.exe"))

    if FFMPEG_CACHE_ROOT.exists():
        candidates.extend(FFMPEG_CACHE_ROOT.rglob("ffmpeg.exe"))

    for candidate in candidates:
        if candidate.exists():
            return candidate

    install_command = [
        "winget",
        "install",
        "--id",
        "Gyan.FFmpeg.Essentials",
        "-e",
        "--accept-package-agreements",
        "--accept-source-agreements",
    ]
    print("Installing ffmpeg via winget ...")
    result = subprocess.run(install_command, capture_output=True, text=True)
    if result.returncode != 0:
        raise RuntimeError(
            "Failed to install ffmpeg via winget.\n"
            f"stdout:\n{result.stdout}\n\nstderr:\n{result.stderr}"
        )

    if local_app_data:
        winget_root = Path(local_app_data) / "Microsoft" / "WinGet" / "Packages"
        if winget_root.exists():
            installed = next(winget_root.rglob("ffmpeg.exe"), None)
            if installed is not None:
                return installed

    raise RuntimeError("ffmpeg.exe could not be located after installation")


def convert_to_mp3(ffmpeg_path: Path, source: Path, destination: Path) -> None:
    import subprocess

    command = [
        str(ffmpeg_path),
        "-y",
        "-i",
        str(source),
        "-codec:a",
        "libmp3lame",
        "-q:a",
        "2",
        str(destination),
    ]
    result = subprocess.run(command, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
    if result.returncode != 0:
        stderr = result.stderr.decode("utf-8", errors="replace")
        raise RuntimeError(
            f"ffmpeg conversion failed for {source}\n"
            f"stderr:\n{stderr}"
        )


if __name__ == "__main__":
    raise SystemExit(main())
