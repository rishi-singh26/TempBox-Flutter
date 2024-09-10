class AttachmentData {
  final String id;
  final String filename;
  final String contentType;
  final String disposition;
  final String transferEncoding;
  final bool related;
  final int size;
  final String downloadUrl;

  AttachmentData({
    required this.id,
    required this.filename,
    required this.contentType,
    required this.disposition,
    required this.transferEncoding,
    required this.related,
    required this.size,
    required this.downloadUrl,
  });

  // Factory method to create MessageData from a JSON object
  factory AttachmentData.fromJson(Map<String, dynamic> json) {
    return AttachmentData(
      id: json['id'],
      filename: json['filename'],
      contentType: json['contentType'],
      disposition: json['disposition'],
      transferEncoding: json['transferEncoding'],
      related: json['related'],
      size: json['size'],
      downloadUrl: json['downloadUrl'],
    );
  }

  // Method to convert MessageData object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'contentType': contentType,
      'disposition': disposition,
      'transferEncoding': transferEncoding,
      'related': related,
      'size': size,
      'downloadUrl': downloadUrl,
    };
  }
}
