import 'package:flutter/material.dart';
import '../models/cart_manager.dart';
import 'cart_screen.dart';
import 'categories_screen.dart';
import 'home_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  late final void Function() _cartListener;

  static const _titles = ['Tech Store', 'Danh mục', 'Giỏ hàng'];

  @override
  void initState() {
    super.initState();
    _cartListener = () {
      if (mounted) setState(() {});
    };
    CartManager.onChanged = _cartListener;
  }

  @override
  void dispose() {
    if (CartManager.onChanged == _cartListener) {
      CartManager.onChanged = null;
    }
    super.dispose();
  }

  void _goToTab(int index) {
    setState(() => _selectedIndex = index);
  }

  void _showCart() {
    _goToTab(2);
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = CartManager.totalQuantity;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: Text(
            _titles[_selectedIndex],
            key: ValueKey(_selectedIndex),
            style: TextStyle(
              fontSize: _selectedIndex == 0 ? 22 : 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ),
        centerTitle: false,
        actions: [
          // Cart icon in app bar
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              tooltip: 'Giỏ hàng ($cartCount)',
              onPressed: _showCart,
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Badge.count(
                count: cartCount > 99 ? 99 : cartCount,
                isLabelVisible: cartCount > 0,
                backgroundColor: const Color(0xFFFF3366),
                textStyle: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
                child: const Icon(Icons.shopping_bag_outlined, size: 22),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(context, cartCount),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: IndexedStack(
          key: ValueKey(_selectedIndex),
          index: _selectedIndex,
          children: <Widget>[
            const HomeScreen(),
            const CategoriesScreen(),
            CartPanel(onContinueShoppingWhenEmpty: () => _goToTab(0)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, cartCount),
    );
  }

  Widget _buildBottomBar(BuildContext context, int cartCount) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
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
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
                label: 'Trang chủ',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.category_outlined,
                selectedIcon: Icons.category_rounded,
                label: 'Danh mục',
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.shopping_bag_outlined,
                selectedIcon: Icons.shopping_bag_rounded,
                label: 'Giỏ hàng',
                index: 2,
                badgeCount: cartCount,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    int badgeCount = 0,
  }) {
    final isSelected = _selectedIndex == index;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => _goToTab(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary.withAlpha(20) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Badge.count(
              count: badgeCount > 99 ? 99 : badgeCount,
              isLabelVisible: badgeCount > 0,
              backgroundColor: const Color(0xFFFF3366),
              textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
              child: Icon(
                isSelected ? selectedIcon : icon,
                size: 24,
                color: isSelected ? colorScheme.primary : colorScheme.onSurface.withAlpha(128),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? colorScheme.primary : colorScheme.onSurface.withAlpha(128),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, int cartCount) {
    final colorScheme = Theme.of(context).colorScheme;
    return Drawer(
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer header
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              left: 24,
              right: 24,
              bottom: 24,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0077ED), Color(0xFF5856D6)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withAlpha(128), width: 2),
                  ),
                  child: const CircleAvatar(
                    radius: 32,
                    backgroundImage: NetworkImage(
                      'https://cdn.iconscout.com/icon/free/png-256/free-avatar-370-456322.png',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nguyễn Văn Linh',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '2224802010841@student.tdmu.edu.vn',
                  style: TextStyle(
                    color: Colors.white.withAlpha(179),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _drawerSection('Menu', [
            _drawerTile(Icons.home_outlined, 'Trang chủ', () => _goToTab(0)),
            _drawerTile(Icons.category_outlined, 'Danh mục', () => _goToTab(1)),
            _drawerTile(Icons.shopping_bag_outlined, 'Giỏ hàng', () => _goToTab(2)),
          ]),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: colorScheme.outlineVariant.withAlpha(80)),
          ),
          _drawerSection('Tài khoản', [
            _drawerTile(
              Icons.payment_outlined,
              'Thanh toán',
              () => Navigator.pushNamed(context, '/checkout'),
              cartCount > 0,
            ),
            _drawerTile(
              Icons.person_outline,
              'Hồ sơ',
              () => Navigator.pushNamed(context, '/profile'),
            ),
          ]),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: colorScheme.outlineVariant.withAlpha(80)),
          ),
          _drawerTile(Icons.logout_outlined, 'Đăng xuất', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã đăng xuất')),
            );
          }),
        ],
      ),
    );
  }

  Widget _drawerSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 16, 4),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _drawerTile(
    IconData icon,
    String label,
    VoidCallback onTap, [
    bool enabled = true,
  ]) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled
              ? colorScheme.primary.withAlpha(20)
              : colorScheme.onSurface.withAlpha(13),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? colorScheme.primary : colorScheme.onSurface.withAlpha(77),
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: enabled ? colorScheme.onSurface : colorScheme.onSurface.withAlpha(100),
        ),
      ),
      enabled: enabled,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: enabled
          ? () {
              Navigator.pop(context);
              onTap();
            }
          : null,
    );
  }
}
