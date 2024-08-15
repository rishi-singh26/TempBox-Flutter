import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:tempbox/macos_views/views/mac_app_info/mac_library_liceses_detail.dart';
import 'package:tempbox/macos_views/views/macui_address_info/macos_card.dart';

class MacLibraryLicense extends StatefulWidget {
  const MacLibraryLicense({super.key});

  @override
  CupertinoUILicensePageState createState() => CupertinoUILicensePageState();
}

class CupertinoUILicensePageState extends State<MacLibraryLicense> {
  final ValueNotifier<int?> selectedId = ValueNotifier<int?>(null);

  final Future<LicenseData> licenses = LicenseRegistry.licenses
      .fold<LicenseData>(
        LicenseData(),
        (LicenseData prev, LicenseEntry license) => prev..addLicense(license),
      )
      .then((LicenseData licenseData) => licenseData..sortPackages());

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return MacosSheet(
        insetPadding: EdgeInsets.symmetric(
          horizontal: (constraints.maxWidth - 600) / 2,
          vertical: (constraints.maxHeight - 430) / 2,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TempBox',
                        style: MacosTheme.of(context).typography.title1,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Powered by Flutter',
                        style: MacosTheme.of(context).typography.body,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                  PushButton(
                    controlSize: ControlSize.regular,
                    onPressed: Navigator.of(context).pop,
                    child: const Text('Done'),
                  ),
                ],
              ),
              FutureBuilder<LicenseData>(
                future: licenses,
                builder: ((BuildContext context, AsyncSnapshot<LicenseData> licensesData) {
                  switch (licensesData.connectionState) {
                    case ConnectionState.done:
                      LicenseData? licenseData = licensesData.data;
                      return SizedBox(
                        height: 315,
                        child: MacosCard(
                          isFirst: true,
                          isLast: true,
                          child: ListView.builder(
                            clipBehavior: Clip.hardEdge,
                            shrinkWrap: true,
                            // padding: const EdgeInsets.symmetric(vertical: 20),
                            itemCount: licensesData.data!.packages.length,
                            itemBuilder: (context, index) {
                              String currentPackage = licensesData.data!.packages[index];
                              List<LicenseEntry> packageLicenses =
                                  licenseData!.packageLicenseBindings[currentPackage]!.map((binding) => licenseData.licenses[binding]).toList();
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: MacosListTile(
                                  title: Text(currentPackage),
                                  subtitle: Text('${packageLicenses.length} License${packageLicenses.length > 1 ? 's' : ''}'),
                                  onClick: () => showMacosSheet(
                                    context: context,
                                    builder: (_) => MacLibraryLicesesDetail(licensData: packageLicenses, title: currentPackage),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    default:
                      return const Center(child: CupertinoActivityIndicator());
                  }
                }),
              ),
            ],
          ),
        ),
      );
    });
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
