import 'package:flutter/material.dart';

class ProductCategory {
  final String id;
  final String title;
  final String description;
  final IconData icon;

  const ProductCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });
}

class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String description;
  final String categoryId;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.categoryId,
  });
}

/// Danh mục hiển thị trên màn Categories.
const List<ProductCategory> mockCategories = [
  ProductCategory(
    id: 'cat_phones',
    title: 'Điện thoại',
    description: 'Smartphone flagship và máy Android/iOS mới nhất.',
    icon: Icons.smartphone,
  ),
  ProductCategory(
    id: 'cat_computers',
    title: 'Máy tính & Tablet',
    description: 'Laptop, tablet phục vụ học tập và làm việc.',
    icon: Icons.laptop_mac,
  ),
  ProductCategory(
    id: 'cat_accessories',
    title: 'Phụ kiện & Đồng hồ',
    description: 'Tai nghe, wearable và phụ kiện đi kèm.',
    icon: Icons.watch,
  ),
  ProductCategory(
    id: 'cat_audio',
    title: 'Âm thanh',
    description: 'Loa, tai nghe và thiết bị âm thanh cao cấp.',
    icon: Icons.headphones,
  ),
];

List<Product> productsInCategory(String categoryId) {
  return mockProducts.where((p) => p.categoryId == categoryId).toList();
}

ProductCategory categoryById(String categoryId) {
  return mockCategories.firstWhere(
    (category) => category.id == categoryId,
    orElse: () => mockCategories.first,
  );
}

// Mock Data — Updated to use local assets
final List<Product> mockProducts = [
  Product(
    id: 'p1',
    name: 'iPhone 15 Pro Max',
    price: 1199.99,
    imageUrl: 'assets/images/ip15prm.jpg',
    description:
        'The ultimate iPhone with a titanium design, A17 Pro chip, and a more advanced 48MP Main camera system.',
    categoryId: 'cat_phones',
  ),
  Product(
    id: 'p2',
    name: 'MacBook Pro 14" M3',
    price: 1599.00,
    imageUrl: 'assets/images/mac14m3.jpg',
    description:
        'Mind-blowing head-turning. The new MacBook Pro featuring the M3 chip brings incredible performance and battery life.',
    categoryId: 'cat_computers',
  ),
  Product(
    id: 'p3',
    name: 'AirPods Pro 2',
    price: 249.00,
    imageUrl: 'assets/images/AirpodPro2.jpg',
    description:
        'Re-engineered for richer audio, clearer calls, and up to 2x more Active Noise Cancellation.',
    categoryId: 'cat_accessories',
  ),
  Product(
    id: 'p4',
    name: 'Apple Watch Series 9',
    price: 399.00,
    imageUrl: 'assets/images/AppleWatchSeries9.jpg',
    description: 'A brighter screen, a new double tap gesture, and a faster S9 SiP.',
    categoryId: 'cat_accessories',
  ),
  Product(
    id: 'p5',
    name: 'iPad Pro 11" M4',
    price: 999.00,
    imageUrl: 'assets/images/ipad.jpg',
    description:
        'The ultimate iPad experience with the impossibly thin design, outrageous performance of the M4 chip.',
    categoryId: 'cat_computers',
  ),
  Product(
    id: 'p6',
    name: 'Samsung Galaxy S24 Ultra',
    price: 1299.99,
    imageUrl: 'assets/images/samsungS24.jpg',
    description:
        'Welcome to the era of mobile AI. With Galaxy S24 Ultra, unleash whole new levels of creativity.',
    categoryId: 'cat_phones',
  ),
  Product(
    id: 'p7',
    name: 'Samsung Galaxy Tab S9',
    price: 849.00,
    imageUrl: 'assets/images/sstab.jpg',
    description:
        'Mỏng nhẹ, màn Dynamic AMOLED 2X, S Pen đi kèm, hiệu năng mạnh mẽ với Snapdragon 8 Gen 2.',
    categoryId: 'cat_computers',
  ),
  Product(
    id: 'p9',
    name: 'Google Pixel 8 Pro',
    price: 999.00,
    imageUrl: 'assets/images/gg8pro.jpg',
    description:
        'The best of Google with AI-powered photo and video features, Tensor G3 chip, and 7 years of updates.',
    categoryId: 'cat_phones',
  ),
  Product(
    id: 'p10',
    name: 'Apple HomePod mini',
    price: 99.00,
    imageUrl: 'assets/images/appleHomePodMini.jpg',
    description:
        'Loa thông minh nhỏ gọn, âm thanh 360 độ, tích hợp Siri, điều khiển smart home.',
    categoryId: 'cat_audio',
  ),
  Product(
    id: 'p11',
    name: 'AirPods Max',
    price: 549.00,
    imageUrl: 'assets/images/AirpodMax.jpg',
    description:
        'Tai nghe over-ear cao cấp với Active Noise Cancellation, Spatial Audio và thiết kế premium.',
    categoryId: 'cat_audio',
  ),
  Product(
    id: 'p12',
    name: 'Samsung Galaxy Watch 6',
    price: 299.00,
    imageUrl: 'assets/images/ssgw6.jpg',
    description:
        'Theo dõi sức khoẻ toàn diện, BioActive Sensor, màn hình Super AMOLED sáng nét.',
    categoryId: 'cat_accessories',
  ),
];
