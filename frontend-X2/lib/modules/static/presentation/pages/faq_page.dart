import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/static_page_scaffold.dart';
import '../../../../core/localization/translation_provider.dart';

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem(this.question, this.answer);
}

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  List<_FaqItem> _items(BuildContext context) => [
        _FaqItem(context.tr('faq.q1'), context.tr('faq.a1')),
        _FaqItem(context.tr('faq.q2'), context.tr('faq.a2')),
        _FaqItem(context.tr('faq.q3'), context.tr('faq.a3')),
        _FaqItem(context.tr('faq.q4'), context.tr('faq.a4')),
        _FaqItem(context.tr('faq.q5'), context.tr('faq.a5')),
        _FaqItem(context.tr('faq.q6'), context.tr('faq.a6')),
        _FaqItem(context.tr('faq.q7'), context.tr('faq.a7')),
        _FaqItem(context.tr('faq.q8'), context.tr('faq.a8')),
      ];

  @override
  Widget build(BuildContext context) {
    return StaticPageScaffold(
      title: context.tr('faq.title'),
      subtitle: context.tr('faq.subtitle'),
      child: Column(
        children: _items(context).map((item) => _FaqTile(item: item)).toList(),
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final _FaqItem item;
  const _FaqTile({required this.item});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.item.question,
                      style: GoogleFonts.sora(fontSize: 14.5, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.item.answer,
                  style: GoogleFonts.dmSans(fontSize: 13.5, color: const Color(0xFF64748B), height: 1.6),
                ),
              ),
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
