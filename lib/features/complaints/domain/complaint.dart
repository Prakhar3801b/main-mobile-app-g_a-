class Complaint {
  Complaint({
    this.id,
    required this.localId,
    required this.citizenName,
    required this.citizenContact,
    required this.subject,
    required this.description,
    required this.queueStatus,
    required this.createdAt,
    this.remoteId,
    this.latitude,
    this.longitude,
    this.status = 'registered',
  });

  final int? id;
  final String localId;
  final String citizenName;
  final String citizenContact;
  final String subject;
  final String description;
  final String queueStatus;
  final String createdAt;
  final int? remoteId;
  final double? latitude;
  final double? longitude;
  final String status;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'local_id': localId,
      'citizen_name': citizenName,
      'citizen_contact': citizenContact,
      'subject': subject,
      'description': description,
      'queue_status': queueStatus,
      'created_at': createdAt,
      'remote_id': remoteId,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
    };
  }

  factory Complaint.fromMap(Map<String, dynamic> map) {
    return Complaint(
      id: map['id'] as int?,
      localId: map['local_id'] as String,
      citizenName: map['citizen_name'] as String,
      citizenContact: map['citizen_contact'] as String,
      subject: map['subject'] as String,
      description: map['description'] as String,
      queueStatus: map['queue_status'] as String,
      createdAt: map['created_at'] as String,
      remoteId: map['remote_id'] as int?,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      status: (map['status'] as String?) ?? 'registered',
    );
  }

  Complaint copyWith({
    int? id,
    String? queueStatus,
    int? remoteId,
    double? latitude,
    double? longitude,
    String? status,
  }) {
    return Complaint(
      id: id ?? this.id,
      localId: localId,
      citizenName: citizenName,
      citizenContact: citizenContact,
      subject: subject,
      description: description,
      queueStatus: queueStatus ?? this.queueStatus,
      createdAt: createdAt,
      remoteId: remoteId ?? this.remoteId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
    );
  }
}
