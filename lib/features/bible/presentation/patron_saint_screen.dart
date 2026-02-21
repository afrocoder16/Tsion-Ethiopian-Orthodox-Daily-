import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/adapters/screen_state_adapters.dart';
import '../../../core/providers/screen_state_providers.dart';

class PatronSaintScreen extends ConsumerStatefulWidget {
  const PatronSaintScreen({super.key, required this.name});

  final String name;

  @override
  ConsumerState<PatronSaintScreen> createState() => _PatronSaintScreenState();
}

class _PatronSaintScreenState extends ConsumerState<PatronSaintScreen> {
  bool _feastReminderEnabled = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(booksScreenStateProvider);
    return Scaffold(
      body: state.when(
        data: (raw) => _PatronSaintContent(
          view: BooksAdapter(raw).patronSaintProfile,
          reminderEnabled: _feastReminderEnabled,
          onReminderChanged: (value) {
            setState(() {
              _feastReminderEnabled = value;
            });
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            const Center(child: Text('Unable to load patron saint')),
      ),
    );
  }
}

class _PatronSaintContent extends StatelessWidget {
  const _PatronSaintContent({
    required this.view,
    required this.reminderEnabled,
    required this.onReminderChanged,
  });

  final PatronSaintProfileView view;
  final bool reminderEnabled;
  final ValueChanged<bool> onReminderChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF3EEF8), Color(0xFFF8F5EE)],
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
          children: [
            Row(
              children: [
                _HeaderButton(icon: Icons.close, onTap: () => context.pop()),
                const Spacer(),
                _HeaderButton(icon: Icons.favorite_border, onTap: () {}),
                const SizedBox(width: 10),
                _HeaderButton(icon: Icons.ios_share, onTap: () {}),
              ],
            ),
            const SizedBox(height: 18),
            const _SaintPortrait(),
            const SizedBox(height: 20),
            Text(
              view.title.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 42,
                height: 1.05,
                fontWeight: FontWeight.w700,
                fontFamily: 'serif',
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE7DA),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFDED3BC)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.event, size: 16, color: Color(0xFF8A6E30)),
                    const SizedBox(width: 8),
                    Text(
                      view.feastDayLabel,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5E4A1F),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              view.summary,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                height: 1.45,
                color: Color(0xFF3E3948),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: view.tags
                  .map((tag) => _QualityChip(label: tag))
                  .toList(),
            ),
            const SizedBox(height: 18),
            _ActionCard(
              icon: Icons.lock_outline,
              title: view.changeTitle,
              subtitle: view.changeSubtitle,
              trailing: const Icon(
                Icons.chevron_right,
                color: Color(0xFF7A6642),
                size: 28,
              ),
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _ActionCard(
              icon: Icons.notifications_none,
              title: view.reminderTitle,
              trailing: Switch(
                value: reminderEnabled,
                onChanged: onReminderChanged,
              ),
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _ContentCard(
              icon: Icons.menu_book_outlined,
              title: view.lifeTitle,
              readTime: view.lifeReadTime,
              body: view.lifeBody,
            ),
            const SizedBox(height: 12),
            _ContentCard(
              icon: Icons.music_note,
              title: view.hymnTitle,
              readTime: view.hymnReadTime,
              body: view.hymnBody,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFE9E4EF),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFD6CCDE)),
        ),
        child: Icon(icon, size: 23, color: const Color(0xFF4D4658)),
      ),
    );
  }
}

class _SaintPortrait extends StatelessWidget {
  const _SaintPortrait();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 222,
        height: 222,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x40BFA66A),
              blurRadius: 28,
              spreadRadius: 8,
            ),
          ],
          border: Border.all(color: const Color(0xFFD2B983), width: 3),
        ),
        child: Container(
          margin: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF2E8D6), Color(0xFFDCC49E)],
            ),
          ),
          child: const Icon(Icons.person, size: 116, color: Color(0xFF866D42)),
        ),
      ),
    );
  }
}

class _QualityChip extends StatelessWidget {
  const _QualityChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFECE4D2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD8C8A9)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 18,
          color: Color(0xFF6D5A34),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF3EEE4),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE0D3BA)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE9DFC8),
              ),
              child: Icon(icon, color: const Color(0xFF8A723D), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF776E60),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({
    required this.icon,
    required this.title,
    required this.readTime,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String readTime;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EEE4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0D3BA)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE9DFC8),
                ),
                child: Icon(icon, color: Color(0xFF8A723D), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'serif',
                        color: Color(0xFF2C262D),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      readTime,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6B6154),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 35,
                height: 35,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE9DFC8),
                ),
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF796540),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Text(
            body,
            style: const TextStyle(
              fontSize: 18,
              height: 1.45,
              color: Color(0xFF3F3944),
            ),
          ),
        ],
      ),
    );
  }
}
