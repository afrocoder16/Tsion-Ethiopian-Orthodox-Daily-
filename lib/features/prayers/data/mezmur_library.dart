import 'dart:convert';

import 'package:flutter/services.dart';

class MezmurTrack {
  const MezmurTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.trackNumber,
    required this.assetPath,
    required this.format,
    required this.isCompilation,
    required this.searchText,
  });

  factory MezmurTrack.fromJson(Map<String, dynamic> json) {
    return MezmurTrack(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      album: json['album'] as String,
      trackNumber: json['trackNumber'] as int,
      assetPath: json['assetPath'] as String,
      format: json['format'] as String,
      isCompilation: json['isCompilation'] as bool,
      searchText: json['searchText'] as String,
    );
  }

  final String id;
  final String title;
  final String artist;
  final String album;
  final int trackNumber;
  final String assetPath;
  final String format;
  final bool isCompilation;
  final String searchText;
}

class MezmurArtistSummary {
  const MezmurArtistSummary({
    required this.name,
    required this.albumCount,
    required this.trackCount,
  });

  final String name;
  final int albumCount;
  final int trackCount;
}

class MezmurAlbumSummary {
  const MezmurAlbumSummary({
    required this.name,
    required this.artist,
    required this.trackCount,
    required this.isCompilation,
  });

  final String name;
  final String artist;
  final int trackCount;
  final bool isCompilation;
}

class MezmurLibrary {
  const MezmurLibrary({required this.tracks});

  final List<MezmurTrack> tracks;

  int get artistCount => tracks
      .where((track) => !track.isCompilation)
      .map((track) => track.artist)
      .toSet()
      .length;

  int get albumCount => tracks
      .where((track) => !track.isCompilation)
      .map((track) => '${track.artist}|${track.album}')
      .toSet()
      .length;

  int get compilationCount => tracks
      .where((track) => track.isCompilation)
      .map((track) => track.album)
      .toSet()
      .length;

  List<MezmurTrack> filter(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return tracks;
    }
    return tracks
        .where((track) => track.searchText.contains(normalized))
        .toList(growable: false);
  }

  List<MezmurArtistSummary> artistSummaries(List<MezmurTrack> filteredTracks) {
    final grouped = <String, List<MezmurTrack>>{};
    for (final track in filteredTracks.where((item) => !item.isCompilation)) {
      grouped.putIfAbsent(track.artist, () => <MezmurTrack>[]).add(track);
    }
    final summaries = grouped.entries
        .map(
          (entry) => MezmurArtistSummary(
            name: entry.key,
            albumCount: entry.value.map((track) => track.album).toSet().length,
            trackCount: entry.value.length,
          ),
        )
        .toList(growable: false);
    summaries.sort((left, right) => left.name.compareTo(right.name));
    return summaries;
  }

  List<MezmurAlbumSummary> albumSummaries(List<MezmurTrack> filteredTracks) {
    final grouped = <String, List<MezmurTrack>>{};
    for (final track in filteredTracks.where((item) => !item.isCompilation)) {
      grouped
          .putIfAbsent('${track.artist}|${track.album}', () => <MezmurTrack>[])
          .add(track);
    }
    final summaries = grouped.entries
        .map((entry) {
          final tracks = entry.value;
          final first = tracks.first;
          return MezmurAlbumSummary(
            name: first.album,
            artist: first.artist,
            trackCount: tracks.length,
            isCompilation: false,
          );
        })
        .toList(growable: false);
    summaries.sort((left, right) {
      final artistOrder = left.artist.compareTo(right.artist);
      if (artistOrder != 0) {
        return artistOrder;
      }
      return left.name.compareTo(right.name);
    });
    return summaries;
  }

  List<MezmurAlbumSummary> compilationSummaries(
    List<MezmurTrack> filteredTracks,
  ) {
    final grouped = <String, List<MezmurTrack>>{};
    for (final track in filteredTracks.where((item) => item.isCompilation)) {
      grouped.putIfAbsent(track.album, () => <MezmurTrack>[]).add(track);
    }
    final summaries = grouped.entries
        .map(
          (entry) => MezmurAlbumSummary(
            name: entry.key,
            artist: entry.key,
            trackCount: entry.value.length,
            isCompilation: true,
          ),
        )
        .toList(growable: false);
    summaries.sort((left, right) => left.name.compareTo(right.name));
    return summaries;
  }
}

class MezmurLibraryRepository {
  const MezmurLibraryRepository();

  static const String _assetPath = 'assets/data/mezmur_library.json';

  Future<MezmurLibrary> load() async {
    final raw = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final tracks = (decoded['tracks'] as List<dynamic>)
        .map((item) => MezmurTrack.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
    return MezmurLibrary(tracks: tracks);
  }
}
