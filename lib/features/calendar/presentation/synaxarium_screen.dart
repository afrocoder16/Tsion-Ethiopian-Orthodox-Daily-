import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_paths.dart';
import '../../../core/providers/calendar_day_detail_providers.dart';

class SynaxariumScreen extends ConsumerWidget {
  const SynaxariumScreen({super.key, required this.dateKey});

  final String dateKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(calendarDayDetailProvider(dateKey));
    final entryState = ref.watch(synaxariumEntryProvider(dateKey));
    final bookmarkedState = ref.watch(synaxariumBookmarkedProvider(dateKey));

    return detailState.when(
      data: (detail) => entryState.when(
        data: (entry) {
          final prepared = _prepareSynaxariumText(entry?.text ?? '');
          final body = _bodyWithoutIntro(prepared);
          final isBookmarked = bookmarkedState.maybeWhen(
            data: (value) => value,
            orElse: () => false,
          );
          return Scaffold(
            appBar: AppBar(
              title: const Text('Read Synaxarium'),
              leading: BackButton(
                onPressed: () => context.pop(),
              ),
              actions: [
                IconButton(
                  tooltip: 'Saved days',
                  onPressed: () =>
                      context.push(RoutePaths.calendarSynaxariumBookmarksPath()),
                  icon: const Icon(Icons.bookmarks_outlined),
                ),
                IconButton(
                  tooltip: isBookmarked ? 'Remove saved day' : 'Save day',
                  onPressed: entry == null
                      ? null
                      : () async {
                          await ref
                              .read(synaxariumRepositoryProvider)
                              .toggleBookmark(entry.key);
                          ref.invalidate(synaxariumBookmarkedProvider(dateKey));
                          ref.invalidate(synaxariumBookmarksProvider(0));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isBookmarked
                                      ? 'Removed from saved days'
                                      : 'Saved day',
                                ),
                              ),
                            );
                          }
                        },
                  icon: Icon(
                    isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                  ),
                ),
                IconButton(
                  tooltip: 'Copy reading',
                  onPressed: prepared.trim().isEmpty
                      ? null
                      : () async {
                          await Clipboard.setData(ClipboardData(text: prepared));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Copied reading')),
                            );
                          }
                        },
                  icon: const Icon(Icons.copy_rounded),
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  detail.ethiopianDate,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                if (detail.saints.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: detail.saints
                        .map(
                          (saint) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F7F7),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: const Color(0xFFE0E0E0)),
                            ),
                            child: Text(
                              saint.name,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 12),
                if (prepared.isEmpty)
                  const Text(
                    'No Synaxarium entry found for this day.',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF7F1E7), Color(0xFFF1E9DD)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE0D1BA)),
                    ),
                    child: SelectableText.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text:
                                'IN THE NAME OF THE FATHER AND THE SON AND THE HOLY SPIRIT, ONE GOD. AMEN.\n\n',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1F1A14),
                              height: 1.7,
                            ),
                          ),
                          TextSpan(
                            text: body,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.7,
                              color: Color(0xFF1F1A14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, stackTrace) => Scaffold(
          appBar: AppBar(title: const Text('Read Synaxarium')),
          body: const Center(child: Text('Unable to load Synaxarium text.')),
        ),
      ),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: const Text('Read Synaxarium')),
        body: Center(
          child: FilledButton(
            onPressed: () => ref.refresh(calendarDayDetailProvider(dateKey)),
            child: const Text('Retry'),
          ),
        ),
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
  final lines = text
      .split('\n')
      .map((line) => line.trim())
      .where((line) {
        if (line.isEmpty) {
          return false;
        }
        final l = line.toLowerCase();
        return l != 'back to' &&
            l != 'list' &&
            l != 'next' &&
            l != 'previous' &&
            !l.startsWith('the first month') &&
            !l.startsWith('the second month') &&
            !l.startsWith('the third month') &&
            !l.startsWith('the fourth month') &&
            !l.startsWith('the fifth month') &&
            !l.startsWith('the sixth month') &&
            !l.startsWith('the seventh month') &&
            !l.startsWith('the eighth month') &&
            !l.startsWith('the nineth month') &&
            !l.startsWith('the ninth month') &&
            !l.startsWith('the tenth month') &&
            !l.startsWith('the eleventh month') &&
            !l.startsWith('the twelfth month') &&
            !l.startsWith('the thirteenth month');
      })
      .toList();
  return '$introNeedle\n\n${lines.join(' ')}'.trim();
}

String _bodyWithoutIntro(String text) {
  const intro = 'IN THE NAME OF THE FATHER AND THE SON AND THE HOLY SPIRIT, ONE GOD. AMEN.';
  if (text.startsWith(intro)) {
    return text.substring(intro.length).trim();
  }
  return text;
}
