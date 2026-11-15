class Certificate {
  final String id;
  final String title;
  final String category;
  final String organizerId;
  final DateTime issueDate;
  final String filePath;
  final String fileType; // 'image' or 'pdf'
  final String? certificateNumber;
  final String? description;
  final bool isFavorite;

  Certificate({
    required this.id,
    required this.title,
    required this.category,
    required this.organizerId,
    required this.issueDate,
    required this.filePath,
    required this.fileType,
    this.certificateNumber,
    this.description,
    this.isFavorite = false,
  });

  Certificate copyWith({
    String? id,
    String? title,
    String? category,
    String? organizerId,
    DateTime? issueDate,
    String? filePath,
    String? fileType,
    String? certificateNumber,
    String? description,
    bool? isFavorite,
  }) {
    return Certificate(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      organizerId: organizerId ?? this.organizerId,
      issueDate: issueDate ?? this.issueDate,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      certificateNumber: certificateNumber ?? this.certificateNumber,
      description: description ?? this.description,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'organizerId': organizerId,
      'issueDate': issueDate.toIso8601String(),
      'filePath': filePath,
      'fileType': fileType,
      'certificateNumber': certificateNumber,
      'description': description,
      'isFavorite': isFavorite,
    };
  }

  factory Certificate.fromMap(Map<String, dynamic> map) {
    return Certificate(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? 'Lainnya',
      organizerId: map['organizerId'] ?? '',
      issueDate: DateTime.tryParse(map['issueDate'] ?? '') ?? DateTime.now(),
      filePath: map['filePath'] ?? '',
      fileType: map['fileType'] ?? 'image',
      certificateNumber: map['certificateNumber'],
      description: map['description'],
      isFavorite: map['isFavorite'] ?? false,
    );
  }
}
