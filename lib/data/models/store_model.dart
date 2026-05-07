class StoreModel {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final String? logoUrl;
  final double rating;
  final int reviewCount;
  final String distance;
  final bool isOpen;
  final String address;
  final String category;

  const StoreModel({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    this.logoUrl,
    this.rating = 0,
    this.reviewCount = 0,
    this.distance = '',
    this.isOpen = true,
    this.address = '',
    this.category = '',
  });
}
