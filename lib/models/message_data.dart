import 'package:tempbox/models/attachment_data.dart';

class MessageData {
  final String id;
  final String accountId;
  final String msgid;
  final String intro;
  final Map<String, String> from;
  final List<Map<String, String>> to;
  final List<String> cc;
  final List<String> bcc;
  final String subject;
  final bool seen;
  final bool flagged;
  final bool isDeleted;
  final Map<String, dynamic> verifications;
  final bool retention;
  final DateTime? retentionDate;
  final String text;
  final List<String> html;
  final bool hasAttachments;
  final List<AttachmentData> attachments;
  final int size;
  final String downloadUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  MessageData({
    required this.id,
    required this.accountId,
    required this.msgid,
    required this.intro,
    required this.from,
    required this.to,
    required this.cc,
    required this.bcc,
    required this.subject,
    required this.seen,
    required this.flagged,
    required this.isDeleted,
    required this.verifications,
    required this.retention,
    this.retentionDate,
    required this.text,
    required this.html,
    required this.hasAttachments,
    required this.attachments,
    required this.size,
    required this.downloadUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory method to create MessageData from a JSON object
  factory MessageData.fromJson(Map<String, dynamic> json) {
    return MessageData(
      id: json.containsKey('id') ? json['id'] : '',
      accountId: json.containsKey('accountId') ? json['accountId'] : '',
      msgid: json.containsKey('msgid') ? json['msgid'] : '',
      intro: json.containsKey('intro') ? json['intro'] : '',
      from: json.containsKey('from') ? Map<String, String>.from(json['from']) : {},
      to: json.containsKey('to') ? List<Map<String, String>>.from(json['to'].map((item) => Map<String, String>.from(item))) : [],
      cc: json.containsKey('cc') ? List<String>.from(json['cc']) : [],
      bcc: json.containsKey('bcc') ? List<String>.from(json['bcc']) : [],
      subject: json.containsKey('subject') ? json['subject'] : '',
      seen: json.containsKey('seen') ? json['seen'] : false,
      flagged: json.containsKey('flagged') ? json['flagged'] : false,
      isDeleted: json.containsKey('isDeleted') ? json['isDeleted'] : false,
      verifications: json.containsKey('verifications') ? Map<String, dynamic>.from(json['verifications']) : {},
      retention: json.containsKey('retention') ? json['retention'] : false,
      retentionDate: json.containsKey('retentionDate') && json['retentionDate'] != null ? DateTime.parse(json['retentionDate']) : null,
      text: json.containsKey('text') ? json['text'] : '',
      html: json.containsKey('html') ? List<String>.from(json['html']) : [],
      hasAttachments: json.containsKey('hasAttachments') ? json['hasAttachments'] : false,
      attachments: json.containsKey('attachments') ? List<AttachmentData>.from(json['attachments'].map((item) => AttachmentData.fromJson(item))) : [],
      size: json.containsKey('size') ? json['size'] : 0,
      downloadUrl: json.containsKey('downloadUrl') ? json['downloadUrl'] : '',
      createdAt: json.containsKey('createdAt') ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json.containsKey('updatedAt') ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  // Method to convert MessageData object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'msgid': msgid,
      'intro': intro,
      'from': from,
      'to': to.map((item) => Map<String, String>.from(item)).toList(),
      'cc': cc,
      'bcc': bcc,
      'subject': subject,
      'seen': seen,
      'flagged': flagged,
      'isDeleted': isDeleted,
      'verifications': verifications,
      'retention': retention,
      'retentionDate': retentionDate?.toIso8601String(),
      'text': text,
      'html': html,
      'hasAttachments': hasAttachments,
      'attachments': attachments.map((item) => item.toJson()).toList(),
      'size': size,
      'downloadUrl': downloadUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
