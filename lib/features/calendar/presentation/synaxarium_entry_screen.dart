import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/calendar_day_detail_providers.dart';

class SynaxariumEntryScreen extends ConsumerStatefulWidget {
  const SynaxariumEntryScreen({super.key, required this.ethKey});

  final String ethKey;

  @override
  ConsumerState<SynaxariumEntryScreen> createState() =>
      _SynaxariumEntryScreenState();
}

class _SynaxariumEntryScreenState extends ConsumerState<SynaxariumEntryScreen> {
  bool _isSaved = false;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) {
      return;
    }
    _loaded = true;
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final repo = ref.read(synaxariumRepositoryProvider);
    final value = await repo.isBookmarked(widget.ethKey);
    if (!mounted) {
      return;
    }
    setState(() {
      _isSaved = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final entryState = ref.watch(synaxariumEntryByKeyProvider(widget.ethKey));
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ethKey),
        actions: [
          IconButton(
            tooltip: _isSaved ? 'Remove saved day' : 'Save day',
            onPressed: () async {
              await ref.read(synaxariumRepositoryProvider).toggleBookmark(
                    widget.ethKey,
                  );
              await _loadSaved();
              ref.invalidate(synaxariumBookmarksProvider(0));
            },
            icon: Icon(
              _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            ),
          ),
          IconButton(
            tooltip: 'Copy reading',
            onPressed: entryState.maybeWhen(
              data: (entry) {
                final text = _prepareSynaxariumText(entry?.text ?? '');
                if (text.isEmpty) {
                  return null;
                }
                return () async {
                  await Clipboard.setData(ClipboardData(text: text));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied reading')),
                    );
                  }
                };
              },
              orElse: () => null,
            ),
            icon: const Icon(Icons.copy_rounded),
          ),
        ],
      ),
      body: entryState.when(
        data: (entry) {
          if (entry == null) {
            return const Center(child: Text('Entry not found'));
          }
          final text = _prepareSynaxariumText(entry.text);
          final body = _bodyWithoutIntro(text);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (entry.saints.isNotEmpty)
                Text(
                  entry.saints.join(', '),
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              const SizedBox(height: 12),
              SelectableText.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text:
                          'IN THE NAME OF THE FATHER AND THE SON AND THE HOLY SPIRIT, ONE GOD. AMEN.\n\n',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                    TextSpan(
                      text: body,
                      style: const TextStyle(fontSize: 15, height: 1.7),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            const Center(child: Text('Unable to load entry')),
      ),
    );
  }
}

String _prepareSynaxariumText(String raw) {
  var text = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  text = text
      .replaceAll('Ã‚', '')
      .replaceAll('Ð°', '')
      .replaceAll('â€œ', '"')
      .replaceAll('â€', '"')
      .replaceAll('â€™', "'")
      .replaceAll('â€“', '-')
      .replaceAll(RegExp(r'[ \t]+'), ' ');
  final introNeedle =
      'IN THE NAME OF THE FATHER AND THE SON AND THE HOLY SPIRIT, ONE GOD. AMEN.';
  final normalizedForSearch = text
      .replaceAll('\n', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .toUpperCase();
  final idx = normalizedForSearch.indexOf(
    'IN THE NAME OF THE FATHER AND THE SON AND THE HOLY SPIRIT',
  );
  if (idx >= 0) {
    final compact = text.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ');
    final tail = compact.substring(idx).trim();
    return '$introNeedle\n\n${tail.replaceFirst(RegExp(r'^IN THE NAME OF THE FATHER AND THE SON AND THE HOLY SPIRIT,?\s*ONE GOD\.?\s*AMEN\.?', caseSensitive: false), '').trim()}';
  }
  return '$introNeedle\n\n$text'.trim();
}

String _bodyWithoutIntro(String text) {
  const intro = 'IN THE NAME OF THE FATHER AND THE SON AND THE HOLY SPIRIT, ONE GOD. AMEN.';
  if (text.startsWith(intro)) {
    return text.substring(intro.length).trim();
  }
  return text;
}
