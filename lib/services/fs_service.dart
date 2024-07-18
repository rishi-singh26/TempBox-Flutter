// import 'dart:async';
// import 'dart:io';
// import 'dart:math';
// import 'package:file_picker/file_picker.dart';
// import 'package:my_maps/models/map_item.dart';
// import 'package:my_maps/models/map_item_category.dart';
// import 'package:my_maps/services/ui_service.dart';
// import 'package:xml/xml.dart' as xml;

// class FSService {
//   /// Pick file
//   /// pass allowedExtns array to add accepted file types
//   /// pass allowedMultiple = true if you want to pick multiple files
//   static Future<PickFileResp> pickFile([
//     List<String> allowedExtns = const [],
//     bool allowMultiple = false,
//   ]) async {
//     try {
//       // Check if allowedExtns is empty
//       FilePickerResult? result = allowedExtns.isEmpty
//           ? await FilePicker.platform.pickFiles(
//               allowMultiple: allowMultiple,
//             )
//           : await FilePicker.platform.pickFiles(
//               type: FileType.custom,
//               allowedExtensions: allowedExtns,
//               allowMultiple: allowMultiple,
//             );
//       if (result != null) {
//         File file = File(result.files.single.path ?? '');
//         return PickFileResp(file: file, status: true);
//       } else {
//         return PickFileResp(file: File('dummy_path'), status: false);
//       }
//     } catch (e) {
//       return PickFileResp(file: File('dummy_path'), status: false);
//     }
//   }

//   /// Pick a directory form filesystem
//   static Future<PickDirResp> pickDirectory() async {
//     try {
//       String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
//       if (selectedDirectory == null) {
//         // User canceled the picker
//         return PickDirResp(
//           path: '',
//           status: false,
//           message: 'Picker cancelled',
//         );
//       }
//       return PickDirResp(
//         path: selectedDirectory,
//         status: true,
//         message: 'Success',
//       );
//     } catch (e) {
//       return PickDirResp(
//         path: '',
//         status: false,
//         message: e.toString(),
//       );
//     }
//   }

//   /// Read file contents
//   /// Pass the file to be read a parameter
//   static Future<ReadFileResp> readFileContents(File file) async {
//     try {
//       // Read the file
//       final contents = await file.readAsString();
//       return ReadFileResp(contents: contents, status: true);
//     } catch (e) {
//       // If encountering an error, return status = false
//       return ReadFileResp(contents: '', status: false);
//     }
//   }

//   /// Write contents to a file
//   /// Pass the file to be written a parameter
//   static Future<WriteFileResp> writeFileContents(File file, String text) async {
//     // Write the file
//     try {
//       File writtenFile = await file.writeAsString(text);
//       return WriteFileResp(file: writtenFile, status: true, message: 'Success');
//     } catch (e) {
//       return WriteFileResp(file: file, status: false, message: e.toString());
//     }
//   }

//   static Future<SaveFileResp> saveFile(String fileData, String filename) async {
//     if (filename.isEmpty) {
//       return SaveFileResp(
//         file: File('dummy_path'),
//         status: false,
//         message: 'Empty file name',
//       );
//     }
//     PickDirResp dirResp = await pickDirectory();
//     if (!dirResp.status) {
//       return SaveFileResp(
//         file: File('dummy_path'),
//         status: false,
//         message: dirResp.message,
//       );
//     }
//     String filePath = '${dirResp.path}/$filename';
//     WriteFileResp writeFileResp = await writeFileContents(File(filePath), fileData);
//     if (!writeFileResp.status) {
//       return SaveFileResp(
//         file: File('dummy_path'),
//         status: false,
//         message: writeFileResp.message,
//       );
//     }
//     return SaveFileResp(
//       file: File(filePath),
//       status: true,
//       message: 'Success',
//     );
//   }

//   static Future<bool> exportGroupDataToKML(
//     String groupName,
//     Map<String, List<MapItem>> categoryMap,
//     List<MapItemCategory> categories,
//   ) async {
//     final String date = UIService.dateToUIString(DateTime.now());
//     final builder = xml.XmlBuilder();
//     builder.processing('xml', 'version="1.0" encoding="UTF-8"');
//     // builder.element('kml', namespaces: {'': 'http://www.opengis.net/kml/2.2'}, nest: () {
//     builder.element('kml', attributes: {'xmlns': 'http://www.opengis.net/kml/2.2'}, nest: () {
//       builder.element('Document', nest: () {
//         builder.element('name', nest: '$groupName $date');

//         // Styles
//         for (var category in categories) {
//           String fillColor = category.fillColor == '00000055' ? '0x55000000' : category.fillColor;
//           // Style for Placemark
//           builder.element('Style', attributes: {'id': '${category.id}:placemarkStyle'}, nest: () {
//             builder.element('IconStyle', nest: () {
//               builder.element('Icon', nest: () {
//                 builder.element('href', nest: 'http://maps.google.com/mapfiles/kml/shapes/placemark_circle.png');
//               });
//             });
//           });

//           // Style for Polygon
//           builder.element('Style', attributes: {'id': '${category.id}:polygonStyle'}, nest: () {
//             builder.element('LineStyle', nest: () {
//               builder.element('color', nest: UIService.getRGBAFromHexCodeColor(category.strokeColor)); // Red line
//               builder.element('width', nest: category.strokeWidth);
//             });
//             builder.element('PolyStyle', nest: () {
//               builder.element('color', nest: UIService.getRGBAFromHexCodeColor(fillColor)); // Translucent red fill
//             });
//           });

//           // Style for Polyline
//           builder.element('Style', attributes: {'id': '${category.id}:polylineStyle'}, nest: () {
//             builder.element('LineStyle', nest: () {
//               builder.element('color', nest: UIService.getRGBAFromHexCodeColor(category.lineColor)); // Green line
//               builder.element('width', nest: category.lineWidth);
//             });
//           });

//           // Style for Circle (approximated with a polygon)
//           builder.element('Style', attributes: {'id': '${category.id}:circleStyle'}, nest: () {
//             builder.element('LineStyle', nest: () {
//               builder.element('color', nest: UIService.getRGBAFromHexCodeColor(category.strokeColor)); // Red line
//               builder.element('width', nest: category.strokeWidth);
//             });
//             builder.element('PolyStyle', nest: () {
//               builder.element('color', nest: UIService.getRGBAFromHexCodeColor(fillColor)); // Translucent blue fill
//             });
//           });
//         }
//         // Iterate through mapItems and add appropriate KML elements
//         categoryMap.forEach((catId, mapItems) {
//           builder.element('Folder', nest: () {
//             builder.element('name', nest: categories.where((c) => c.id == catId).first.name);
//             for (var mapItem in mapItems) {
//               if (mapItem.type == MapItemTypes.placemarker) {
//                 builder.element('Placemark', nest: () {
//                   builder.element('name', nest: mapItem.name);
//                   builder.element('description', nest: mapItem.desc);
//                   builder.element('styleUrl', nest: '#${mapItem.categoryId}:placemarkStyle');
//                   builder.element('Point', nest: () {
//                     builder.element('coordinates', nest: '${mapItem.markerCoords.longitude},${mapItem.markerCoords.latitude}');
//                   });
//                 });
//               } else if (mapItem.type == MapItemTypes.polygon) {
//                 builder.element('Placemark', nest: () {
//                   builder.element('name', nest: mapItem.name);
//                   builder.element('description', nest: mapItem.desc);
//                   builder.element('styleUrl', nest: '#${mapItem.categoryId}:polygonStyle');
//                   builder.element('Polygon', nest: () {
//                     builder.element('outerBoundaryIs', nest: () {
//                       builder.element('LinearRing', nest: () {
//                         var coordinates = mapItem.coords.map((point) => '${point.longitude},${point.latitude}').join(' ');
//                         coordinates += ' ${mapItem.coords.first.longitude},${mapItem.coords.first.latitude}';
//                         builder.element('coordinates', nest: coordinates);
//                       });
//                     });
//                   });
//                 });
//               } else if (mapItem.type == MapItemTypes.polyline) {
//                 builder.element('Placemark', nest: () {
//                   builder.element('name', nest: mapItem.name);
//                   builder.element('description', nest: mapItem.desc);
//                   builder.element('styleUrl', nest: '#${mapItem.categoryId}:polylineStyle');
//                   builder.element('LineString', nest: () {
//                     var coordinates = mapItem.coords.map((point) => '${point.longitude},${point.latitude}').join(' ');
//                     builder.element('coordinates', nest: coordinates);
//                   });
//                 });
//               } else if (mapItem.type == MapItemTypes.circle && mapItem.radius != null) {
//                 builder.element('Placemark', nest: () {
//                   builder.element('name', nest: mapItem.name);
//                   builder.element('description', nest: mapItem.desc);
//                   builder.element('styleUrl', nest: '#${mapItem.categoryId}:circleStyle');
//                   builder.element('Polygon', nest: () {
//                     builder.element('outerBoundaryIs', nest: () {
//                       builder.element('LinearRing', nest: () {
//                         var circleCoordinates = _generateCircleCoordinates(
//                           mapItem.markerCoords.latitude, mapItem.markerCoords.longitude,
//                           mapItem.radius!, 36, // Number of points to approximate the circle
//                         );
//                         builder.element('coordinates', nest: circleCoordinates);
//                       });
//                     });
//                   });
//                 });
//               }
//             }
//           });
//         });
//       });
//     });

//     // Build the XML document
//     final kmlDocument = builder.buildDocument();

//     // Write the KML content to a file
//     await saveFile(
//       kmlDocument.toXmlString(pretty: true),
//       '$groupName $date.kml',
//     );
//     return true;
//   }

//   static String _generateCircleCoordinates(double lat, double lon, double radius, int numPoints) {
//     const double deg2rad = 3.141592653589793 / 180.0;
//     // const double rad2deg = 180.0 / 3.141592653589793;
//     final List<String> coordinates = [];

//     for (int i = 0; i < numPoints; i++) {
//       double angle = (360 / numPoints) * i;
//       double theta = angle * deg2rad;
//       double latitude = lat + (radius * 0.00001) * cos(theta);
//       double longitude = lon + (radius * 0.00001) * sin(theta) / cos(lat * deg2rad);
//       coordinates.add('$longitude,$latitude');
//     }

//     // Close the circle by adding the first coordinate at the end
//     coordinates.add(coordinates.first);

//     return coordinates.join(' ');
//   }
// }

// class PickFileResp {
//   final bool status;
//   final File file;
//   PickFileResp({required this.file, required this.status});
// }

// class PickDirResp {
//   final bool status;
//   final String path;
//   final String message;
//   PickDirResp({
//     required this.path,
//     required this.status,
//     required this.message,
//   });
// }

// class ReadFileResp {
//   final String contents;
//   final bool status;
//   ReadFileResp({required this.contents, required this.status});
// }

// class WriteFileResp {
//   final File file;
//   final bool status;
//   final String message;
//   WriteFileResp({
//     required this.file,
//     required this.status,
//     required this.message,
//   });
// }

// class SaveFileResp {
//   final File file;
//   final bool status;
//   final String message;
//   SaveFileResp({
//     required this.file,
//     required this.status,
//     required this.message,
//   });
// }
