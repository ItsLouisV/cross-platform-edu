import 'product.dart';

/// Một dòng trong giỏ hàng: sản phẩm + số lượng.
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;
}

class CartManager {
  // Giỏ hàng gom theo sản phẩm (key = product.id)
  static final Map<String, CartItem> _items = {};

  /// Danh sách các dòng trong giỏ.
  static List<CartItem> get items => _items.values.toList();

  /// Tổng số lượng sản phẩm (tất cả dòng cộng lại).
  static int get totalQuantity =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  /// Gọi khi giỏ thay đổi (ví dụ MainShell cập nhật Drawer).
  static void Function()? onChanged;

  static void _notify() => onChanged?.call();

  /// Thêm 1 sản phẩm. Nếu đã có thì tăng số lượng.
  static void addProduct(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity++;
    } else {
      _items[product.id] = CartItem(product: product);
    }
    _notify();
  }

  /// Đặt số lượng cụ thể cho sản phẩm. Nếu quantity <= 0 thì xoá.
  static void setQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      _items.remove(productId);
    } else {
      _items[productId]?.quantity = quantity;
    }
    _notify();
  }

  /// Xoá hoàn toàn sản phẩm khỏi giỏ.
  static void removeProduct(String productId) {
    _items.remove(productId);
    _notify();
  }

  static void clearCart() {
    _items.clear();
    _notify();
  }

  static double get totalPrice {
    return _items.values.fold(0, (sum, item) => sum + item.subtotal);
  }
}
