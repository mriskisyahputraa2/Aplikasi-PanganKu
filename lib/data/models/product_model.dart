class ProductModel {
  final int id;
  final String name;
  final int price;
  final int stock;
  final String description;
  final String category;
  final String? imageUrl;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.description,
    required this.category,
    this.imageUrl,
  });

  // Parsing dari JSON Laravel
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],

      // [PERBAIKAN DISINI]
      // 1. json['price'] dikonversi ke String dulu (jaga-jaga)
      // 2. Di-parse ke double (karena ada .00)
      // 3. Di-convert ke int (dibulatkan)
      price: double.parse(json['price'].toString()).toInt(),

      stock: json['stock'] ?? 0,
      description: json['description'] ?? '',
      category: json['category'] ?? 'Umum',
      imageUrl: json['image_url'],
    );
  }
}
