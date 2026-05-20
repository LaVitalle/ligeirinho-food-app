class StoreModel {
  final String id;
  final String institutionId;
  final String name;
  final String description;
  final String? imageUrl;
  final String? logoUrl;
  final String? cnpj;
  final String? block;
  final String? room;
  final double rating;
  final int reviewCount;
  final String distance;
  final bool isOpen;
  final String address;
  final String category;
  final DateTime? createdAt;

  const StoreModel({
    required this.id,
    required this.name,
    this.institutionId = '',
    required this.description,
    this.imageUrl,
    this.logoUrl,
    this.cnpj,
    this.block,
    this.room,
    this.rating = 0,
    this.reviewCount = 0,
    this.distance = '',
    this.isOpen = true,
    this.address = '',
    this.category = '',
    this.createdAt,
  });

  StoreModel copyWith({
    String? id,
    String? institutionId,
    String? name,
    String? description,
    String? imageUrl,
    String? logoUrl,
    String? cnpj,
    String? block,
    String? room,
    double? rating,
    int? reviewCount,
    String? distance,
    bool? isOpen,
    String? address,
    String? category,
    DateTime? createdAt,
  }) {
    return StoreModel(
      id: id ?? this.id,
      institutionId: institutionId ?? this.institutionId,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      cnpj: cnpj ?? this.cnpj,
      block: block ?? this.block,
      room: room ?? this.room,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      distance: distance ?? this.distance,
      isOpen: isOpen ?? this.isOpen,
      address: address ?? this.address,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    final block = json['block']?.toString();
    final room = json['room']?.toString();
    final location = [block, room].where((value) => value != null && value.isNotEmpty).join(' · ');

    return StoreModel(
      id: json['id']?.toString() ?? '',
      institutionId: json['institutionId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: location.isNotEmpty ? location : 'Cantina da instituição',
      logoUrl: json['logoUrl']?.toString(),
      cnpj: json['cnpj']?.toString(),
      block: block,
      room: room,
      isOpen: json['isOpen'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      address: location,
    );
  }
}
