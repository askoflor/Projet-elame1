import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/static_page_scaffold.dart';
import '../../../../core/localization/translation_provider.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StaticPageScaffold(
      title: context.tr('about.title'),
      subtitle: context.tr('about.subtitle'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _paragraph(context.tr('about.intro')),
          const SizedBox(height: 28),
          _sectionTitle(context.tr('about.missionTitle')),
          _paragraph(context.tr('about.missionText')),
          const SizedBox(height: 28),
          _sectionTitle(context.tr('about.howTitle')),
          _bulletList([
            context.tr('about.how1'),
            context.tr('about.how2'),
            context.tr('about.how3'),
            context.tr('about.how4'),
          ]),
          const SizedBox(height: 28),
          _sectionTitle(context.tr('about.valuesTitle')),
          _bulletList([
            context.tr('about.value1'),
            context.tr('about.value2'),
            context.tr('about.value3'),
            context.tr('about.value4'),
          ]),
          const SizedBox(height: 28),
          _sectionTitle(context.tr('about.joinTitle')),
          _paragraph(context.tr('about.joinText')),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          text,
          style: GoogleFonts.sora(fontSize: 19, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
        ),
      );

  Widget _paragraph(String text) => Text(
        text,
        style: GoogleFonts.dmSans(fontSize: 14.5, color: const Color(0xFF475569), height: 1.7),
      );

  Widget _bulletList(List<String> items) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 6, right: 10),
                        child: Icon(Icons.circle, size: 6, color: Color(0xFF2563EB)),
                      ),
                      Expanded(
                        child: Text(
                          item,
                          style: GoogleFonts.dmSans(fontSize: 14.5, color: const Color(0xFF475569), height: 1.6),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      );
}
