import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

class WinUILibraryLicesesDetail extends StatelessWidget {
  final String title;
  final List<LicenseEntry> licensData;
  const WinUILibraryLicesesDetail({
    super.key,
    required this.licensData,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return ContentDialog(
        constraints: const BoxConstraints(maxWidth: 600),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: FluentTheme.of(context).typography.title),
            FilledButton(onPressed: Navigator.of(context).pop, child: const Text('Done')),
          ],
        ),
        content: ListView.builder(
          shrinkWrap: true,
          itemCount: licensData.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Text(licensData[index].paragraphs.map((paragraph) => paragraph.text).join("\n\n")),
            );
          },
        ),
      );
    });
  }
}
