// services/issue_service.dart
import 'dart:io';
import '../models/issue_model.dart';

class IssueService {
  static final IssueService _instance = IssueService._internal();
  factory IssueService() => _instance;
  IssueService._internal();

  /// Submit a new issue
  Future<Map<String, dynamic>> submitIssue({
    required String reporterId,
    required String reporterName,
    required String reporterRole,
    required IssueCategory category,
    required String description,
    List<File>? photos,
    String? relatedDonationId,
    String? relatedTaskId,
  }) async {
    try {
      // Upload photos first if any
      List<String> photoUrls = [];
      if (photos != null && photos.isNotEmpty) {
        photoUrls = await _uploadPhotos(photos);
      }

      // Create issue object
      final issue = Issue(
        id: 'issue_${DateTime.now().millisecondsSinceEpoch}',
        reporterId: reporterId,
        reporterName: reporterName,
        reporterRole: reporterRole,
        category: category,
        description: description,
        photoUrls: photoUrls,
        relatedDonationId: relatedDonationId,
        relatedTaskId: relatedTaskId,
        createdAt: DateTime.now(),
      );

      // In production, send to backend
      // final response = await http.post(
      //   Uri.parse('$_baseUrl/api/issues/report'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: json.encode(issue.toJson()),
      // );

      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock success response
      return {
        'success': true,
        'issueId': issue.id,
        'message': 'Issue reported successfully',
        'issue': issue.toJson(),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to submit issue: $e',
      };
    }
  }

  /// Upload photos to server
  Future<List<String>> _uploadPhotos(List<File> photos) async {
    List<String> urls = [];

    for (var photo in photos) {
      try {
        // In production, upload to cloud storage (S3, Firebase Storage, etc.)
        // For now, return mock URLs
        final mockUrl =
            'https://storage.example.com/issues/${DateTime.now().millisecondsSinceEpoch}_${photos.indexOf(photo)}.jpg';
        urls.add(mockUrl);

        // Simulate upload delay
        await Future.delayed(const Duration(milliseconds: 200));
      } catch (e) {
        print('Failed to upload photo: $e');
      }
    }

    return urls;
  }

  /// Get all issues for a user
  Future<List<Issue>> getUserIssues(String userId) async {
    try {
      // In production, fetch from backend
      // final response = await http.get(
      //   Uri.parse('$_baseUrl/api/issues/user/$userId'),
      // );

      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock data
      return [];
    } catch (e) {
      print('Failed to fetch issues: $e');
      return [];
    }
  }

  /// Get issue by ID
  Future<Issue?> getIssueById(String issueId) async {
    try {
      // In production, fetch from backend
      // final response = await http.get(
      //   Uri.parse('$_baseUrl/api/issues/$issueId'),
      // );

      await Future.delayed(const Duration(milliseconds: 300));

      return null;
    } catch (e) {
      print('Failed to fetch issue: $e');
      return null;
    }
  }

  /// Get category display name
  String getCategoryDisplayName(IssueCategory category) {
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

  /// Get all issue categories
  List<Map<String, dynamic>> getAllCategories() {
    return [
      {
        'category': IssueCategory.foodQuality,
        'name': 'Food Quality Issue',
        'icon': 'restaurant',
      },
      {
        'category': IssueCategory.deliveryDelay,
        'name': 'Delivery Delay',
        'icon': 'access_time',
      },
      {
        'category': IssueCategory.wrongAddress,
        'name': 'Wrong Address',
        'icon': 'location_off',
      },
      {
        'category': IssueCategory.contactIssue,
        'name': 'Contact Issue',
        'icon': 'phone_disabled',
      },
      {
        'category': IssueCategory.quantityMismatch,
        'name': 'Quantity Mismatch',
        'icon': 'scale',
      },
      {
        'category': IssueCategory.other,
        'name': 'Other Issue',
        'icon': 'help_outline',
      },
    ];
  }
}
