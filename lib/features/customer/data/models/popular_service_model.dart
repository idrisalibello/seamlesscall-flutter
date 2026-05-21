// lib/features/customer/data/models/popular_service_model.dart
//
// Returned by GET /api/v1/customer/services/popular.
// Extends the plain Service with popularity metrics so the home screen
// can show booking counts and ratings alongside the service name.

class PopularService {
  final int id;
  final int categoryId;
  final String categoryName;
  final String name;
  final String? description;
  final String? status;
  final int bookingCount;
  final double avgRating;
  final int ratingCount;
  final int viewCount;
  final double popularityScore;

  const PopularService({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.name,
    this.description,
    this.status,
    required this.bookingCount,
    required this.avgRating,
    required this.ratingCount,
    required this.viewCount,
    required this.popularityScore,
  });

  static int _i(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _d(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  factory PopularService.fromMap(Map<String, dynamic> map) {
    return PopularService(
      id:              _i(map['id']),
      categoryId:      _i(map['category_id']),
      categoryName:    (map['category_name'] ?? '').toString(),
      name:            (map['name'] ?? '').toString(),
      description:     map['description']?.toString(),
      status:          map['status']?.toString(),
      bookingCount:    _i(map['booking_count']),
      avgRating:       _d(map['avg_rating']),
      ratingCount:     _i(map['rating_count']),
      viewCount:       _i(map['view_count']),
      popularityScore: _d(map['popularity_score']),
    );
  }

  /// Star rating string for display, e.g. "4.5 ★"
  String get ratingLabel {
    if (ratingCount == 0) return 'New';
    return '${avgRating.toStringAsFixed(1)} ★';
  }

  /// Short booking label, e.g. "12 bookings"
  String get bookingLabel {
    if (bookingCount == 0) return 'Be the first';
    return '$bookingCount booking${bookingCount == 1 ? '' : 's'}';
  }
}