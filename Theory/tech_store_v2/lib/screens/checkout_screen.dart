import 'package:flutter/material.dart';
import '../models/cart_manager.dart';
import '../widgets/section_header.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final double shippingFee = 15;
  final double taxRate = 0.05;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (CartManager.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Thanh toán')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary.withAlpha(20),
                ),
                child: Icon(Icons.shopping_cart_checkout_rounded,
                    size: 36, color: colorScheme.primary.withAlpha(153)),
              ),
              const SizedBox(height: 20),
              const Text('Không có sản phẩm để thanh toán',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('Vui lòng thêm sản phẩm vào giỏ hàng.',
                  style: TextStyle(color: colorScheme.onSurface.withAlpha(128))),
            ],
          ),
        ),
      );
    }

    final subTotal = CartManager.totalPrice;
    final tax = subTotal * taxRate;
    final total = subTotal + tax + shippingFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // ── Shipping Form ──
          const SectionHeader(
            title: 'Thông tin giao hàng',
            subtitle: 'Điền đầy đủ để xử lý đơn hàng',
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorScheme.outlineVariant.withAlpha(100)),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    validator: _requiredValidator,
                    decoration: const InputDecoration(
                      labelText: 'Họ và tên',
                      prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    keyboardType: TextInputType.phone,
                    validator: _requiredValidator,
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại',
                      prefixIcon: Icon(Icons.phone_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    validator: _requiredValidator,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Địa chỉ nhận hàng',
                      prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Order Summary ──
          const SectionHeader(title: 'Tổng quan đơn hàng'),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorScheme.outlineVariant.withAlpha(100)),
            ),
            child: Column(
              children: [
                _summaryRow('Tạm tính', subTotal, colorScheme),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(height: 1, color: colorScheme.outlineVariant.withAlpha(60)),
                ),
                _summaryRow('Thuế (5%)', tax, colorScheme),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(height: 1, color: colorScheme.outlineVariant.withAlpha(60)),
                ),
                _summaryRow('Phí giao hàng', shippingFee, colorScheme),
                const SizedBox(height: 16),
                Container(height: 1.5, color: colorScheme.outlineVariant),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Tổng thanh toán',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: colorScheme.outlineVariant.withAlpha(80))),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 20, offset: const Offset(0, -4)),
          ],
        ),
        child: ElevatedButton(
          onPressed: () => _placeOrder(context, total),
          child: Text('Xác nhận đặt hàng • \$${total.toStringAsFixed(2)}'),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, double amount, ColorScheme colorScheme) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: colorScheme.onSurface.withAlpha(153))),
        const Spacer(),
        Text('\$${amount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  void _placeOrder(BuildContext context, double total) {
    if (!_formKey.currentState!.validate()) return;
    CartManager.clearCart();

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 32, right: 32, top: 32,
          bottom: MediaQuery.of(ctx).padding.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE8F5E9),
              ),
              child: const Icon(Icons.check_circle_rounded, size: 48, color: Color(0xFF4CAF50)),
            ),
            const SizedBox(height: 20),
            const Text('Đặt hàng thành công!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Đơn hàng của bạn đang được xử lý.',
                style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              child: const Text('Về trang chủ'),
            ),
          ],
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập trường này';
    return null;
  }
}
