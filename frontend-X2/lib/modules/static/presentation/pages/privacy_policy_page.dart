import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/static_page_scaffold.dart';
import '../../../../core/localization/translation_provider.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StaticPageScaffold(
      title: context.tr('privacy.title'),
      subtitle: context.tr('privacy.subtitle'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _notice(context.tr('privacy.notice')),
          const SizedBox(height: 28),
          _section(context.tr('privacy.s1Title'), context.tr('privacy.s1Text')),
          _section(
            context.tr('privacy.s2Title'),
            context.tr('privacy.s2Text'),
            bullets: [
              context.tr('privacy.s2B1'),
              context.tr('privacy.s2B2'),
              context.tr('privacy.s2B3'),
              context.tr('privacy.s2B4'),
              context.tr('privacy.s2B5'),
            ],
          ),
          _section(
            context.tr('privacy.s3Title'),
            context.tr('privacy.s3Text'),
            bullets: [
              context.tr('privacy.s3B1'),
              context.tr('privacy.s3B2'),
              context.tr('privacy.s3B3'),
              context.tr('privacy.s3B4'),
              context.tr('privacy.s3B5'),
              context.tr('privacy.s3B6'),
            ],
          ),
          _section(context.tr('privacy.s4Title'), context.tr('privacy.s4Text')),
          _section(
            context.tr('privacy.s5Title'),
            context.tr('privacy.s5Text'),
            bullets: [
              context.tr('privacy.s5B1'),
              context.tr('privacy.s5B2'),
              context.tr('privacy.s5B3'),
            ],
            footer: context.tr('privacy.s5Footer'),
          ),
          _section(context.tr('privacy.s6Title'), context.tr('privacy.s6Text')),
          _section(
            context.tr('privacy.s7Title'),
            context.tr('privacy.s7Text'),
            bullets: [
              context.tr('privacy.s7B1'),
              context.tr('privacy.s7B2'),
              context.tr('privacy.s7B3'),
              context.tr('privacy.s7B4'),
              context.tr('privacy.s7B5'),
            ],
            footer: context.tr('privacy.s7Footer'),
          ),
          _section(context.tr('privacy.s8Title'), context.tr('privacy.s8Text')),
          _section(context.tr('privacy.s9Title'), context.tr('privacy.s9Text')),
          _section(context.tr('privacy.s10Title'), context.tr('privacy.s10Text')),
          _section(context.tr('privacy.s11Title'), context.tr('privacy.s11Text')),
        ],
      ),
    );
  }

  Widget _notice(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF2563EB)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.dmSans(fontSize: 13, color: const Color(0xFF1E3A8A), height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, String intro, {List<String>? bullets, String? footer}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.sora(fontSize: 17, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
          ),
          const SizedBox(height: 10),
          Text(
            intro,
            style: GoogleFonts.dmSans(fontSize: 14, color: const Color(0xFF475569), height: 1.7),
          ),
          if (bullets != null) ...[
            const SizedBox(height: 10),
            ...bullets.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 6, right: 10),
                        child: Icon(Icons.circle, size: 5, color: Color(0xFF2563EB)),
                      ),
                      Expanded(
                        child: Text(
                          b,
                          style: GoogleFonts.dmSans(fontSize: 13.5, color: const Color(0xFF475569), height: 1.6),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
          if (footer != null) ...[
            const SizedBox(height: 10),
            Text(
              footer,
              style: GoogleFonts.dmSans(fontSize: 13.5, fontStyle: FontStyle.italic, color: const Color(0xFF64748B), height: 1.6),
            ),
          ],
        ],
      ),
    );
  }
}
