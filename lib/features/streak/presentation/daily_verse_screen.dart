import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_paths.dart';
import '../../../core/adapters/screen_state_adapters.dart';
import '../../../core/providers/screen_state_providers.dart';

class DailyVerseScreen extends ConsumerStatefulWidget {
  const DailyVerseScreen({super.key});

  @override
  ConsumerState<DailyVerseScreen> createState() => _DailyVerseScreenState();
}

class _DailyVerseScreenState extends ConsumerState<DailyVerseScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(todayScreenStateProvider);
      ref.invalidate(dailyVersePageProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dailyVersePageProvider);
    return state.when(
      data: (page) => _DailyVerseContent(view: page),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Unable to load daily verse'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.refresh(todayScreenStateProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyVerseContent extends StatelessWidget {
  const _DailyVerseContent({required this.view});

  final DailyVersePageView view;

  @override
  Widget build(BuildContext context) {
    final verse = view.verseCard;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Daily Verse'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F3EE),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE4DBCF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Verse of the Day',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    verse.reference,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: 42,
                    height: 3,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB79C5E),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    verse.fullBody,
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.7,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (verse.bookId != null && verse.chapter != null) ...[
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => context.go(
                          RoutePaths.biblePassagePath(
                            verse.bookId!,
                            verse.chapter!,
                          ),
                        ),
                        icon: const Icon(Icons.menu_book_rounded, size: 18),
                        label: const Text('Read full in Bible'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB79C5E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  const Text(
                    'Carry this verse with you through the day.',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
            if (view.supportingReadings.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                children: const [
                  Expanded(child: Divider(color: Color(0xFFE4DBCF))),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Other Qidase Readings',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black54,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Color(0xFFE4DBCF))),
                ],
              ),
              const SizedBox(height: 16),
              ...view.supportingReadings.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SupportingReadingCard(item: item),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SupportingReadingCard extends StatelessWidget {
  const _SupportingReadingCard({required this.item});

  final DailyVerseSupportingItemView item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5DED4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F3EE),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              item.label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            item.reference,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.body,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => context.go(
                  RoutePaths.biblePassagePath(item.bookId, item.chapter),
                ),
                icon: const Icon(Icons.menu_book_rounded, size: 16),
                label: const Text('Read full in Bible'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF8F7244),
                  side: const BorderSide(color: Color(0xFFDBC8A2)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const Spacer(),
              if (item.isPreviewTruncated)
                const Text(
                  'Preview',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

void _showInfoDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('About today\'s readings'),
      content: const Text(
        'The top card is the Gospel reading for today. Under it, you will see '
        'the other Qidase readings for the same day: Pauline, Catholic, Acts, '
        'and Psalm. You can open any of them in the Bible and continue at your '
        'own pace.',
        style: TextStyle(height: 1.45),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}
