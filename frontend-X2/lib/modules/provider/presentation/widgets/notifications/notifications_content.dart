import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/localization/translation_provider.dart';
import '../../../../../core/widgets/micro_interactions.dart';
import '../../../state/provider_dashboard_state.dart';
import '../../../domain/notification_model.dart';

const Color _primary = Color(0xFF2563EB);
const Color _textPrimary = Color(0xFF1E293B);
const Color _textSecondary = Color(0xFF64748B);
const Color _textMuted = Color(0xFF94A3B8);
const Color _border = Color(0xFFE8ECF2);

class NotificationsContent extends StatefulWidget {
  const NotificationsContent({super.key});

  @override
  State<NotificationsContent> createState() => _NotificationsContentState();
}

class _NotificationsContentState extends State<NotificationsContent> {
  int _selectedFilter = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProviderDashboardProvider>();
    final tr = context.tr;
    final filters = [tr('notifications.filterToutes'), tr('notifications.filterNonLues')];
    final notifs = _selectedFilter == 0
        ? provider.notifications
        : provider.notifications.where((n) => !n.lu).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(tr, provider),
        const SizedBox(height: 16),
        _buildFilters(filters),
        const SizedBox(height: 16),
        if (notifs.isEmpty)
          _buildEmptyState(tr)
        else
          _buildGroupedNotifications(context, notifs, provider, tr),
      ],
    );
  }

  Widget _buildHeader(String Function(String) tr, ProviderDashboardProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr('provider.notifications'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _textPrimary, fontFamily: 'Sora')),
            const SizedBox(height: 4),
            Text('${provider.notifications.length} ${tr('provider.totalNotifications')}', style: const TextStyle(fontSize: 13, color: _textSecondary, fontFamily: 'DM Sans')),
          ],
        ),
        if (provider.notificationsNonLues > 0)
          PointerCursor(
            child: GestureDetector(
              onTap: () => provider.marquerToutesNotificationsLues(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: _primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(tr('provider.toutMarquerLu'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _primary, fontFamily: 'DM Sans')),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFilters(List<String> filters) {
    return Row(
      children: List.generate(filters.length, (index) {
        final filter = filters[index];
        final isSelected = _selectedFilter == index;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: PointerCursor(
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? _primary : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isSelected ? _primary : _border),
                ),
                child: Text(filter, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : _textSecondary, fontFamily: 'DM Sans')),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(String Function(String) tr) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.notifications_off_rounded, size: 48, color: _textMuted.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text(tr('provider.aucuneNotification'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: _textSecondary, fontFamily: 'DM Sans')),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedNotifications(BuildContext context, List<ProviderNotification> notifs, ProviderDashboardProvider provider, String Function(String) tr) {
    final grouped = <String, List<ProviderNotification>>{};
    for (final n in notifs) {
      final key = _groupeKey(context, n.date);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(n);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(entry.key, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textMuted, fontFamily: 'DM Sans')),
              ),
              ...entry.value.map((n) => _buildNotificationItem(context, n, provider, tr)),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _groupeKey(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return context.tr('notifications.groupeAujourdhui');
    if (diff.inHours < 24) return context.tr('notifications.groupeAujourdhui');
    if (diff.inDays < 2) return context.tr('notifications.groupeHier');
    if (diff.inDays < 7) return context.tr('notifications.groupeCetteSemaine');
    return context.tr('notifications.groupePlusTot');
  }

  Widget _buildNotificationItem(BuildContext context, ProviderNotification notif, ProviderDashboardProvider provider, String Function(String) tr) {
    return PointerCursor(
      child: GestureDetector(
        onTap: () => provider.marquerNotificationLue(notif.id),
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: notif.lu ? Colors.white : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: notif.lu ? _border : _primary.withOpacity(0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _iconColor(notif.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_iconFor(notif.type), size: 18, color: _iconColor(notif.type)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(notif.titre, style: TextStyle(fontSize: 13, fontWeight: notif.lu ? FontWeight.w500 : FontWeight.w600, color: _textPrimary, fontFamily: 'DM Sans'))),
                        if (!notif.lu)
                          Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: _primary)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(notif.message, style: const TextStyle(fontSize: 12, color: _textSecondary, fontFamily: 'DM Sans', height: 1.4)),
                    const SizedBox(height: 6),
                    Text(_timeAgo(context, notif.date), style: const TextStyle(fontSize: 11, color: _textMuted, fontFamily: 'DM Sans')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(NotificationType type) {
    return switch (type) {
      NotificationType.nouvelleMission => Icons.rocket_launch_rounded,
      NotificationType.missionAnnulee => Icons.cancel_outlined,
      NotificationType.missionCompletee => Icons.task_alt_rounded,
      NotificationType.paiementRecu => Icons.monetization_on_rounded,
      NotificationType.evaluationRecue => Icons.star_rounded,
      NotificationType.rappel => Icons.notifications_active_rounded,
      NotificationType.info => Icons.info_outline_rounded,
    };
  }

  Color _iconColor(NotificationType type) {
    return switch (type) {
      NotificationType.nouvelleMission => const Color(0xFF2563EB),
      NotificationType.missionAnnulee => const Color(0xFFEF4444),
      NotificationType.missionCompletee => const Color(0xFF16A34A),
      NotificationType.paiementRecu => const Color(0xFFF59E0B),
      NotificationType.evaluationRecue => const Color(0xFF8B5CF6),
      NotificationType.rappel => const Color(0xFFF97316),
      NotificationType.info => const Color(0xFF06B6D4),
    };
  }

  String _timeAgo(BuildContext context, DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return context.tr('notifications.aInstant');
    if (diff.inMinutes < 60) return context.tr('notifications.ilYAMin').replaceFirst('{0}', '${diff.inMinutes}');
    if (diff.inHours < 24) return context.tr('notifications.ilYAHeures').replaceFirst('{0}', '${diff.inHours}');
    if (diff.inDays < 7) return context.tr('notifications.ilYAJours').replaceFirst('{0}', '${diff.inDays}');
    return '${date.day}/${date.month}/${date.year}';
  }
}
