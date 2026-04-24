import 'package:flutter/material.dart';
import '../models/cart_manager.dart';
import '../widgets/empty_state.dart';

class CartPanel extends StatefulWidget {
  const CartPanel({super.key, required this.onContinueShoppingWhenEmpty});

  final VoidCallback onContinueShoppingWhenEmpty;

  @override
  State<CartPanel> createState() => _CartPanelState();
}

class _CartPanelState extends State<CartPanel> {
  @override
  Widget build(BuildContext context) {
    final cartItems = CartManager.items;

    if (cartItems.isEmpty) {
      return EmptyState(
        icon: Icons.shopping_bag_outlined,
        title: 'Giỏ hàng đang trống',
        message: 'Hãy thêm sản phẩm yêu thích để bắt đầu đặt hàng.',
        actionLabel: 'Tiếp tục mua sắm',
        onAction: widget.onContinueShoppingWhenEmpty,
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        // Item count header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Row(
            children: [
              Text(
                '${cartItems.length} sản phẩm • ${CartManager.totalQuantity} đơn vị',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface.withAlpha(128),
                ),
              ),
              const Spacer(),
              if (cartItems.length > 1)
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: const Text('Xoá tất cả?'),
                        content: const Text(
                            'Bạn có chắc muốn xoá toàn bộ sản phẩm trong giỏ hàng?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Huỷ'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              setState(() => CartManager.clearCart());
                            },
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.red),
                            child: const Text('Xoá tất cả'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade400,
                    textStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  child: const Text('Xoá tất cả'),
                ),
            ],
          ),
        ),

        // Cart items
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final cartItem = cartItems[index];
              final product = cartItem.product;
              return Dismissible(
                key: ValueKey(product.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  setState(() => CartManager.removeProduct(product.id));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã xoá ${product.name}')),
                  );
                },
                background: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: Icon(Icons.delete_outline_rounded,
                      color: Colors.red.shade400, size: 24),
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withAlpha(80),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Product image
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: product.imageUrl.startsWith('http')
                            ? Image.network(
                                product.imageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => Icon(
                                  Icons.image_outlined,
                                  color: colorScheme.onSurface.withAlpha(64),
                                ),
                              )
                            : Image.asset(
                                product.imageUrl,
                                fit: BoxFit.contain,
                              ),
                      ),
                      const SizedBox(width: 12),
                      // Product info + quantity
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name
                            Text(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Price (unit × qty)
                            Text(
                              '\$${cartItem.subtotal.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Quantity selector row
                            Row(
                              children: [
                                _QuantityControl(
                                  quantity: cartItem.quantity,
                                  onChanged: (newQty) {
                                    setState(() {
                                      CartManager.setQuantity(
                                          product.id, newQty);
                                    });
                                  },
                                ),
                                const Spacer(),
                                // Delete button
                                GestureDetector(
                                  onTap: () {
                                    setState(() =>
                                        CartManager.removeProduct(product.id));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('Đã xoá ${product.name}')),
                                    );
                                  },
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.red.withAlpha(15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.delete_outline_rounded,
                                        size: 16, color: Colors.red.shade400),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // ── Bottom Summary ──
        Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).padding.bottom + 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: colorScheme.outlineVariant.withAlpha(80),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'Tổng cộng (${CartManager.totalQuantity} sản phẩm)',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withAlpha(153),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '\$${CartManager.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/checkout').then((_) {
                    if (mounted) setState(() {});
                  });
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Tiến hành thanh toán'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Inline quantity +/- control widget for cart items.
class _QuantityControl extends StatelessWidget {
  const _QuantityControl({
    required this.quantity,
    required this.onChanged,
  });

  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Minus button
          _button(
            icon: quantity > 1
                ? Icons.remove_rounded
                : Icons.delete_outline_rounded,
            color: quantity > 1
                ? colorScheme.primary
                : Colors.red.shade400,
            enabled: true,
            onTap: () => onChanged(quantity - 1),
          ),
          // Quantity label
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: SizedBox(
              key: ValueKey(quantity),
              width: 32,
              child: Text(
                '$quantity',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
          // Plus button
          _button(
            icon: Icons.add_rounded,
            color: colorScheme.primary,
            enabled: quantity < 99,
            onTap: () => onChanged(quantity + 1),
          ),
        ],
      ),
    );
  }

  Widget _button({
    required IconData icon,
    required Color color,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: enabled ? onTap : null,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: 16, color: enabled ? color : color.withAlpha(64)),
        ),
      ),
    );
  }
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giỏ hàng của bạn')),
      body: CartPanel(
        onContinueShoppingWhenEmpty: () {
          if (Navigator.of(context).canPop()) Navigator.pop(context);
        },
      ),
    );
  }
}
