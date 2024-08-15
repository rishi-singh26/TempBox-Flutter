import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:tempbox/macos_views/views/macui_address_info/macos_card.dart';

class MacLibraryLicesesDetail extends StatelessWidget {
  final String title;
  final List<LicenseEntry> licensData;
  const MacLibraryLicesesDetail({
    super.key,
    required this.licensData,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return MacosSheet(
        insetPadding: EdgeInsets.symmetric(
          horizontal: (constraints.maxWidth - 600) / 2,
          vertical: (constraints.maxHeight - 430) / 2,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: MacosTheme.of(context).typography.title2),
                    PushButton(
                      controlSize: ControlSize.regular,
                      onPressed: Navigator.of(context).pop,
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 360,
                child: MacosCard(
                  isFirst: true,
                  isLast: true,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: licensData.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Text(licensData[index].paragraphs.map((paragraph) => paragraph.text).join("\n\n")),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
