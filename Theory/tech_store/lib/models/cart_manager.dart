import 'product.dart';

class CartManager {
  // Dữ liệu đệm static, sẽ mất đi khi Hot Restart ứng dụng
  static final List<Product> items = [];

  static void addProduct(Product product) {
    items.add(product);
  }

  static void removeProduct(Product product) {
    items.remove(product);
  }

  static void clearCart() {
    items.clear();
  }

  static double get totalPrice {
    return items.fold(0, (sum, item) => sum + item.price);
  }
}
