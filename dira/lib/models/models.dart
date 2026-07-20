import 'package:cloud_firestore/cloud_firestore.dart';

enum StaffRole { admin, doctor, nurse, pharmacist, reception }

extension StaffRoleX on StaffRole {
  String get label => switch (this) {
        StaffRole.admin => 'Admin',
        StaffRole.doctor => 'Doctor',
        StaffRole.nurse => 'Nurse',
        StaffRole.pharmacist => 'Pharmacist',
        StaffRole.reception => 'Reception',
      };
}

enum TicketType { itIssue, restock, staffRequest, patientCallback, general }

extension TicketTypeX on TicketType {
  String get label => switch (this) {
        TicketType.itIssue => 'IT / Equipment Issue',
        TicketType.restock => 'Inventory Restock',
        TicketType.staffRequest => 'Staff Request',
        TicketType.patientCallback => 'Patient Callback',
        TicketType.general => 'General Task',
      };
}

enum TicketStatus { open, inProgress, done }

extension TicketStatusX on TicketStatus {
  String get label => switch (this) {
        TicketStatus.open => 'Open',
        TicketStatus.inProgress => 'In Progress',
        TicketStatus.done => 'Done',
      };
}

enum TicketPriority { low, medium, high, urgent }

class Clinic {
  final String id;
  final String name;
  final String ownerId;
  final DateTime createdAt;
  final String plan;

  Clinic({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.createdAt,
    this.plan = 'trial',
  });

  factory Clinic.fromFirestore(Map<String, dynamic> data, String id) => Clinic(
        id: id,
        name: data['name'] as String? ?? 'Unnamed Clinic',
        ownerId: data['ownerId'] as String? ?? '',
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        plan: data['plan'] as String? ?? 'trial',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'ownerId': ownerId,
        'createdAt': createdAt,
        'plan': plan,
      };
}

class ClinicMember {
  final String uid;
  final String name;
  final String email;
  final StaffRole role;

  ClinicMember({required this.uid, required this.name, required this.email, required this.role});

  factory ClinicMember.fromFirestore(Map<String, dynamic> data, String uid) => ClinicMember(
        uid: uid,
        name: data['name'] as String? ?? '',
        email: data['email'] as String? ?? '',
        role: StaffRole.values.firstWhere((r) => r.name == data['role'], orElse: () => StaffRole.reception),
      );

  Map<String, dynamic> toJson() => {'name': name, 'email': email, 'role': role.name, 'status': 'active'};
}

class ClinicInvite {
  final String id;
  final String email;
  final StaffRole role;
  final String status;

  ClinicInvite({required this.id, required this.email, required this.role, this.status = 'pending'});

  factory ClinicInvite.fromFirestore(Map<String, dynamic> data, String id) => ClinicInvite(
        id: id,
        email: data['email'] as String? ?? '',
        role: StaffRole.values.firstWhere((r) => r.name == data['role'], orElse: () => StaffRole.reception),
        status: data['status'] as String? ?? 'pending',
      );

  Map<String, dynamic> toJson() => {'email': email, 'role': role.name, 'status': status};
}

class Ticket {
  final String id;
  final String title;
  final String description;
  final TicketType type;
  final TicketStatus status;
  final TicketPriority priority;
  final String? assigneeId;
  final String? assigneeName;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? dueDate;

  Ticket({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.priority,
    this.assigneeId,
    this.assigneeName,
    required this.createdBy,
    required this.createdAt,
    this.dueDate,
  });

  factory Ticket.fromFirestore(Map<String, dynamic> data, String id) => Ticket(
        id: id,
        title: data['title'] as String? ?? '',
        description: data['description'] as String? ?? '',
        type: TicketType.values.firstWhere((t) => t.name == data['type'], orElse: () => TicketType.general),
        status: TicketStatus.values.firstWhere((s) => s.name == data['status'], orElse: () => TicketStatus.open),
        priority: TicketPriority.values
            .firstWhere((p) => p.name == data['priority'], orElse: () => TicketPriority.medium),
        assigneeId: data['assigneeId'] as String?,
        assigneeName: data['assigneeName'] as String?,
        createdBy: data['createdBy'] as String? ?? '',
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'type': type.name,
        'status': status.name,
        'priority': priority.name,
        'assigneeId': assigneeId,
        'assigneeName': assigneeName,
        'createdBy': createdBy,
        'createdAt': createdAt,
        'dueDate': dueDate,
      };
}