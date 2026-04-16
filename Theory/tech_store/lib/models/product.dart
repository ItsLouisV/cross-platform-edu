class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
  });
}

// Mock Data
final List<Product> mockProducts = [
  Product(
    id: 'p1',
    name: 'iPhone 15 Pro Max',
    price: 1199.99,
    imageUrl: 'https://cdn.tgdd.vn/Products/Images/42/305658/iphone-15-pro-max-blue-thumbnew-600x600.jpg',
    description: 'The ultimate iPhone with a titanium design, A17 Pro chip, and a more advanced 48MP Main camera system.',
  ),
  Product(
    id: 'p2',
    name: 'MacBook Pro 14" M3',
    price: 1599.00,
    imageUrl: 'https://cdn.tgdd.vn/Products/Images/44/318210/macbook-pro-14-inch-m3-pro-2023-bac-thumb-600x600.jpg',
    description: 'Mind-blowing head-turning. The new MacBook Pro featuring the M3 chip brings incredible performance and battery life.',
  ),
  Product(
    id: 'p3',
    name: 'AirPods Pro 2',
    price: 249.00,
    imageUrl: 'https://cdn.tgdd.vn/Products/Images/54/289781/tai-nghe-bluetooth-airpods-pro-2-magsafe-charge-apple-mqd83-thumb-600x600.jpeg',
    description: 'Re-engineered for richer audio, clearer calls, and up to 2x more Active Noise Cancellation.',
  ),
  Product(
    id: 'p4',
    name: 'Apple Watch Series 9',
    price: 399.00,
    imageUrl: 'https://cdn.tgdd.vn/Products/Images/7077/314706/apple-watch-s9-gps-41mm-vien-nhom-day-silicone-xanh-den-thumb-600x600.jpg',
    description: 'A brighter screen, a new double tap gesture, and a faster S9 SiP.',
  ),
  Product(
    id: 'p5',
    name: 'iPad Pro 11" M4',
    price: 999.00,
    imageUrl: 'https://cdn.tgdd.vn/Products/Images/522/323380/ipad-pro-m4-11-inch-wifi-1-1-600x600.jpg',
    description: 'The ultimate iPad experience with the impossibly thin design, outrageous performance of the M4 chip.',
  ),
  Product(
    id: 'p6',
    name: 'Samsung Galaxy S24 Ultra',
    price: 1299.99,
    imageUrl: 'https://cdn.tgdd.vn/Products/Images/42/307174/samsung-galaxy-s24-ultra-grey-thumb-600x600.jpg',
    description: 'Welcome to the era of mobile AI. With Galaxy S24 Ultra in your hands, you can unleash whole new levels of creativity.',
  ),
];
