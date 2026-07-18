import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/localization/translation_provider.dart';
import '../../../../../core/widgets/micro_interactions.dart';
import '../../../state/provider_dashboard_state.dart';
import '../../../domain/revenue.dart';

const Color _primary = Color(0xFF2563EB);
const Color _textPrimary = Color(0xFF1E293B);
const Color _textSecondary = Color(0xFF64748B);
const Color _textMuted = Color(0xFF94A3B8);
const Color _border = Color(0xFFE8ECF2);
const Color _success = Color(0xFF16A34A);
const Color _error = Color(0xFFEF4444);

class RevenusContent extends StatelessWidget {
  const RevenusContent({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProviderDashboardProvider>();
    final tr = context.tr;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(tr, provider),
        const SizedBox(height: 20),
        _buildSummaryRow(tr, provider),
        const SizedBox(height: 24),
        _buildChart(tr, provider),
        const SizedBox(height: 24),
        _buildRecentRevenus(tr, provider),
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
            Text(
              tr('provider.mesRevenus'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
                fontFamily: 'Sora',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              tr('provider.revenusSub'),
              style: const TextStyle(fontSize: 13, color: _textSecondary, fontFamily: 'DM Sans'),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.trending_up_rounded, size: 16, color: _success),
              const SizedBox(width: 4),
              Text(
                '+${provider.revenueSummary.progression.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _success, fontFamily: 'Sora'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String Function(String) tr, ProviderDashboardProvider provider) {
    final rs = provider.revenueSummary;
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        return GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.8,
          ),
          children: [
            _summaryCard(tr('provider.revenuMois'), '${rs.totalMois.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')} FCFA', Icons.monetization_on_rounded, _primary),
            _summaryCard(tr('provider.revenuAnnee'), '${rs.totalAnnee.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')} FCFA', Icons.calendar_view_month_rounded, _success),
            _summaryCard(tr('provider.missionsTotal'), '${rs.missionsMois}', Icons.work_rounded, const Color(0xFFF59E0B)),
            _summaryCard(tr('provider.moyenneMission'), '${rs.moyenneParMission.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')} FCFA', Icons.analytics_rounded, const Color(0xFF8B5CF6)),
          ],
        );
      },
    );
  }

  Widget _summaryCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: _textSecondary, fontFamily: 'DM Sans')),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textPrimary, fontFamily: 'Sora')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(String Function(String) tr, ProviderDashboardProvider provider) {
    final data = provider.chartData;
    final maxMontant = data.fold<double>(0, (max, p) => p.montant > max ? p.montant : max);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr('provider.evolutionRevenus'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _textPrimary, fontFamily: 'Sora')),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: CustomPaint(
              size: Size.infinite,
              painter: _ChartPainter(data, maxMontant, _primary, _textMuted),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: data.map((p) => Text(p.mois, style: const TextStyle(fontSize: 10, color: _textMuted, fontFamily: 'DM Sans'))).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRevenus(String Function(String) tr, ProviderDashboardProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr('provider.transactionsRecent'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _textPrimary, fontFamily: 'Sora')),
          const SizedBox(height: 16),
          ...provider.recentRevenus.map((r) => _buildTransactionRow(r)),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(Revenue r) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: r.statut == RevenueStatus.paid ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              r.statut == RevenueStatus.paid ? Icons.check_circle : Icons.access_time,
              size: 16,
              color: r.statut == RevenueStatus.paid ? _success : const Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.libelle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _textPrimary, fontFamily: 'DM Sans')),
                const SizedBox(height: 2),
                Text('${r.date.day}/${r.date.month}/${r.date.year}', style: const TextStyle(fontSize: 11, color: _textMuted, fontFamily: 'DM Sans')),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${r.montant.toStringAsFixed(0)} FCFA', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: r.statut == RevenueStatus.paid ? _success : _textSecondary, fontFamily: 'Sora')),
              Text('Net: ${r.net.toStringAsFixed(0)} FCFA', style: const TextStyle(fontSize: 10, color: _textMuted, fontFamily: 'DM Sans')),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<RevenueChartPoint> data;
  final double maxValue;
  final Color barColor;
  final Color axisColor;

  _ChartPainter(this.data, this.maxValue, this.barColor, this.axisColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = barColor.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = barColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    final barWidth = (size.width - 40) / data.length;
    final chartHeight = size.height - 20;

    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = 20 + i * barWidth + barWidth / 2;
      final ratio = maxValue > 0 ? data[i].montant / maxValue : 0.0;
      final y = chartHeight - (ratio * (chartHeight - 20));

      points.add(Offset(x, y));

      final barPaint = Paint()
        ..color = barColor.withOpacity(0.1 + 0.7 * ratio)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromCenter(center: Offset(x, chartHeight - (chartHeight - y) / 2), width: barWidth * 0.5, height: chartHeight - y),
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
        ),
        barPaint,
      );
    }

    if (points.length >= 2) {
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        final prev = points[i - 1];
        final curr = points[i];
        final midX = (prev.dx + curr.dx) / 2;
        path.quadraticBezierTo(prev.dx, prev.dy, midX, (prev.dy + curr.dy) / 2);
        path.quadraticBezierTo(curr.dx, curr.dy, curr.dx, curr.dy);
      }
    }

    canvas.drawPath(path, linePaint);

    for (final point in points) {
      canvas.drawCircle(point, 4, dotPaint);
      canvas.drawCircle(point, 2.5, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
