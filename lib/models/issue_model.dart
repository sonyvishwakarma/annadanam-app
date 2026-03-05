// models/issue_model.dart
enum IssueCategory {
  foodQuality,
  deliveryDelay,
  wrongAddress,
  contactIssue,
  quantityMismatch,
  other,
}

enum IssueStatus {
  reported,
  investigating,
  resolved,
  closed,
}

class Issue {
  final String id;
  final String reporterId;
  final String reporterName;
  final String reporterRole; // donor, volunteer, recipient
  final IssueCategory category;
  final String description;
  final List<String> photoUrls;
  final String? relatedDonationId;
  final String? relatedTaskId;
  final IssueStatus status;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  Issue({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    required this.reporterRole,
    required this.category,
    required this.description,
    this.photoUrls = const [],
    this.relatedDonationId,
    this.relatedTaskId,
    this.status = IssueStatus.reported,
    required this.createdAt,
    this.resolvedAt,
  });

  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(
      id: json['id'] ?? '',
      reporterId: json['reporterId'] ?? '',
      reporterName: json['reporterName'] ?? '',
      reporterRole: json['reporterRole'] ?? 'donor',
      category: _parseCategory(json['category'] ?? 'other'),
      description: json['description'] ?? '',
      photoUrls: List<String>.from(json['photoUrls'] ?? []),
      relatedDonationId: json['relatedDonationId'],
      relatedTaskId: json['relatedTaskId'],
      status: _parseStatus(json['status'] ?? 'reported'),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporterId': reporterId,
      'reporterName': reporterName,
      'reporterRole': reporterRole,
      'category': _categoryToString(category),
      'description': description,
      'photoUrls': photoUrls,
      'relatedDonationId': relatedDonationId,
      'relatedTaskId': relatedTaskId,
      'status': _statusToString(status),
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }

  static IssueCategory _parseCategory(String category) {
    switch (category.toLowerCase()) {
      case 'foodquality':
      case 'food_quality':
        return IssueCategory.foodQuality;
      case 'deliverydelay':
      case 'delivery_delay':
        return IssueCategory.deliveryDelay;
      case 'wrongaddress':
      case 'wrong_address':
        return IssueCategory.wrongAddress;
      case 'contactissue':
      case 'contact_issue':
        return IssueCategory.contactIssue;
      case 'quantitymismatch':
      case 'quantity_mismatch':
        return IssueCategory.quantityMismatch;
      default:
        return IssueCategory.other;
    }
  }

  static IssueStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'investigating':
        return IssueStatus.investigating;
      case 'resolved':
        return IssueStatus.resolved;
      case 'closed':
        return IssueStatus.closed;
      default:
        return IssueStatus.reported;
    }
  }

  static String _categoryToString(IssueCategory category) {
    switch (category) {
      case IssueCategory.foodQuality:
        return 'food_quality';
      case IssueCategory.deliveryDelay:
        return 'delivery_delay';
      case IssueCategory.wrongAddress:
        return 'wrong_address';
      case IssueCategory.contactIssue:
        return 'contact_issue';
      case IssueCategory.quantityMismatch:
        return 'quantity_mismatch';
      case IssueCategory.other:
        return 'other';
    }
  }

  static String _statusToString(IssueStatus status) {
    switch (status) {
      case IssueStatus.reported:
        return 'reported';
      case IssueStatus.investigating:
        return 'investigating';
      case IssueStatus.resolved:
        return 'resolved';
      case IssueStatus.closed:
        return 'closed';
    }
  }

  String getCategoryDisplayName() {
    switch (category) {
      case IssueCategory.foodQuality:
        return 'Food Quality Issue';
      case IssueCategory.deliveryDelay:
        return 'Delivery Delay';
      case IssueCategory.wrongAddress:
        return 'Wrong Address';
      case IssueCategory.contactIssue:
        return 'Contact Issue';
      case IssueCategory.quantityMismatch:
        return 'Quantity Mismatch';
      case IssueCategory.other:
        return 'Other Issue';
    }
  }
}
