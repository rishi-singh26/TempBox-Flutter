import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class LibraryLicesesDetail extends StatelessWidget {
  final String title;
  final List<LicenseEntry> licensData;
  const LibraryLicesesDetail({
    super.key,
    required this.licensData,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(title),
        previousPageTitle: 'Licenses',
      ),
      child: ListView.builder(
        itemCount: licensData.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(15),
            child: Text(
              licensData[index].paragraphs.map((paragraph) => paragraph.text).join("\n\n"),
              // .join("\n===========================\n"),
              style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle.copyWith(
                    fontSize: 14.0,
                  ),
            ),
          );
        },
      ),
    );
  }
}
