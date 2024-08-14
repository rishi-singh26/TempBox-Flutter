import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:tempbox/ios_ui/app_info/library_liceses_detail.dart';
import 'package:tempbox/ios_ui/colors.dart';

class LibraryLicense extends StatefulWidget {
  const LibraryLicense({super.key});

  @override
  CupertinoUILicensePageState createState() => CupertinoUILicensePageState();
}

class CupertinoUILicensePageState extends State<LibraryLicense> {
  final ValueNotifier<int?> selectedId = ValueNotifier<int?>(null);

  final Future<LicenseData> licenses = LicenseRegistry.licenses
      .fold<LicenseData>(
        LicenseData(),
        (LicenseData prev, LicenseEntry license) => prev..addLicense(license),
      )
      .then((LicenseData licenseData) => licenseData..sortPackages());

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: MediaQuery.of(context).platformBrightness != Brightness.dark ? AppColors.navBarColor : null,
        border: null,
        middle: const Text("Licenses"),
        trailing: CupertinoButton(
          onPressed: Navigator.of(context, rootNavigator: true).pop,
          padding: EdgeInsets.zero,
          child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
      child: FutureBuilder<LicenseData>(
        future: licenses,
        builder: ((BuildContext context, AsyncSnapshot<LicenseData> licensesData) {
          switch (licensesData.connectionState) {
            case ConnectionState.done:
              LicenseData? licenseData = licensesData.data;
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 90),
                itemCount: licensesData.data!.packages.length + 1,
                itemBuilder: (context, totalIndex) {
                  if (totalIndex == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'TempBox',
                          style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Powered by Flutter',
                          style: CupertinoTheme.of(context).textTheme.textStyle,
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  }
                  final int index = totalIndex - 1;
                  String currentPackage = licensesData.data!.packages[index];
                  List<LicenseEntry> packageLicenses =
                      licenseData!.packageLicenseBindings[currentPackage]!.map((binding) => licenseData.licenses[binding]).toList();
                  return _Tile(
                    title: currentPackage,
                    subtitle: '${packageLicenses.length} License${packageLicenses.length > 1 ? 's' : ''}',
                    isFirst: index == 0,
                    isLast: index == licensesData.data!.packages.length - 1,
                    onPress: () {
                      Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                        return LibraryLicesesDetail(
                          licensData: packageLicenses,
                          title: currentPackage,
                        );
                      }));
                    },
                  );
                },
              );
            default:
              return const Center(
                child: CupertinoActivityIndicator(),
              );
          }
        }),
      ),
    );
  }
}

class LicenseData {
  final List<LicenseEntry> licenses = <LicenseEntry>[];
  final Map<String, List<int>> packageLicenseBindings = <String, List<int>>{};
  final List<String> packages = <String>[];

  String? firstPackage;

  void addLicense(LicenseEntry entry) {
    // Before the license can be added, we must first record the packages to
    // which it belongs.
    for (final String package in entry.packages) {
      _addPackage(package);
      // Bind this license to the package using the next index value. This
      // creates a contract that this license must be inserted at this same
      // index value.
      packageLicenseBindings[package]!.add(licenses.length);
    }
    licenses.add(entry);
  }

  void _addPackage(String package) {
    if (!packageLicenseBindings.containsKey(package)) {
      packageLicenseBindings[package] = <int>[];
      firstPackage ??= package;
      packages.add(package);
    }
  }

  /// Sort the packages using some comparison method, or by the default manner,
  /// which is to put the application package first, followed by every other
  /// package in case-insensitive alphabetical order.
  void sortPackages([int Function(String a, String b)? compare]) {
    packages.sort(compare ??
        (String a, String b) {
          // Based on how LicenseRegistry currently behaves, the first package
          // returned is the end user application license. This should be
          // presented first in the list. So here we make sure that first package
          // remains at the front regardless of alphabetical sorting.
          if (a == firstPackage) {
            return -1;
          }
          if (b == firstPackage) {
            return 1;
          }
          return a.toLowerCase().compareTo(b.toLowerCase());
        });
  }
}

class _Tile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Function() onPress;
  final bool isFirst;
  final bool isLast;
  const _Tile({
    this.subtitle = '',
    required this.title,
    required this.onPress,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
        margin: const EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(
          color: CupertinoTheme.of(context).barBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isFirst ? 10 : 0),
            topRight: Radius.circular(isFirst ? 10 : 0),
            bottomLeft: Radius.circular(isLast ? 10 : 0),
            bottomRight: Radius.circular(isLast ? 10 : 0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: CupertinoTheme.of(context).textTheme.textStyle,
            ),
            subtitle.isEmpty
                ? const SizedBox()
                : SizedBox(
                    width: 220,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        subtitle,
                        maxLines: 2,
                        style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
