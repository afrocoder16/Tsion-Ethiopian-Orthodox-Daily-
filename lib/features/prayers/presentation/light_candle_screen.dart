import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/adapters/screen_state_adapters.dart';
import '../../../core/providers/screen_state_providers.dart';

class LightCandleScreen extends ConsumerStatefulWidget {
  const LightCandleScreen({super.key});

  @override
  ConsumerState<LightCandleScreen> createState() => _LightCandleScreenState();
}

class _LightCandleScreenState extends ConsumerState<LightCandleScreen> {
  bool _isLiving = true;
  bool _enableFlash = false;
  final TextEditingController _namesController = TextEditingController();

  @override
  void dispose() {
    _namesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(prayersScreenStateProvider);
    return Scaffold(
      body: state.when(
        data: (raw) => _LightCandleContent(
          view: PrayersAdapter(raw).lightCandle,
          isLiving: _isLiving,
          enableFlash: _enableFlash,
          namesController: _namesController,
          onSwitchGroup: (value) => setState(() => _isLiving = value),
          onSwitchFlash: (value) => setState(() => _enableFlash = value),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            const Center(child: Text('Unable to load candle form')),
      ),
    );
  }
}

class _LightCandleContent extends StatelessWidget {
  const _LightCandleContent({
    required this.view,
    required this.isLiving,
    required this.enableFlash,
    required this.namesController,
    required this.onSwitchGroup,
    required this.onSwitchFlash,
  });

  final LightCandleView view;
  final bool isLiving;
  final bool enableFlash;
  final TextEditingController namesController;
  final ValueChanged<bool> onSwitchGroup;
  final ValueChanged<bool> onSwitchFlash;

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
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    view.title,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'serif',
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    view.cancelLabel,
                    style: const TextStyle(
                      fontSize: 22,
                      color: Color(0xFF7B5D2A),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              view.description,
              style: const TextStyle(fontSize: 18, color: Colors.black87),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFEFE8DA),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE0D4BC)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _SegmentButton(
                      isActive: isLiving,
                      icon: Icons.favorite,
                      title: view.livingTitle,
                      subtitle: view.livingSubtitle,
                      onTap: () => onSwitchGroup(true),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _SegmentButton(
                      isActive: !isLiving,
                      icon: Icons.nightlight_round,
                      title: view.departedTitle,
                      subtitle: view.departedSubtitle,
                      onTap: () => onSwitchGroup(false),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              view.namesLabel,
              style: const TextStyle(fontSize: 18, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7F3EA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFDFD4BF)),
              ),
              child: TextField(
                controller: namesController,
                minLines: 6,
                maxLines: 6,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  hintText: view.namesHint,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    view.flashLabel,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                Switch(value: enableFlash, onChanged: onSwitchFlash),
              ],
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.local_fire_department),
              label: Text(
                view.submitLabel,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE7CE8B),
                foregroundColor: const Color(0xFF4F3E1F),
                minimumSize: const Size.fromHeight(62),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.isActive,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool isActive;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF6F1E7) : const Color(0xFFE8E0CF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? const Color(0xFFD9C59F) : const Color(0xFFE0D4BC),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF8A6E30)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
