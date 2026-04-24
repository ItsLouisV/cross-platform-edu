import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';
import '../models/cart_manager.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../widgets/search_bar.dart';
import '../widgets/section_header.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _filteredProducts = mockProducts;
  String _searchQuery = '';
  int _selectedCategory = -1; // -1 = all
  int _currentBanner = 0;

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _applyFilters();
    });
  }

  void _onCategorySelected(int index) {
    setState(() {
      _selectedCategory = index;
      _applyFilters();
    });
  }

  void _applyFilters() {
    if (_selectedCategory < 0) {
      _filteredProducts = mockProducts;
    } else {
      final categoryId = mockCategories[_selectedCategory].id;
      _filteredProducts = productsInCategory(categoryId);
    }
    if (_searchQuery.isNotEmpty) {
      _filteredProducts = _filteredProducts.where((product) {
        return product.name.toLowerCase().contains(_searchQuery);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final featuredProducts = mockProducts.take(3).toList();
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        // ── Search Bar ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SearchBarWidget(onQueryChanged: _onSearchChanged),
          ),
        ),

        // ── Hero Banner Carousel ──
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CarouselSlider.builder(
                itemCount: featuredProducts.length,
                itemBuilder: (context, index, realIndex) {
                  final product = featuredProducts[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailScreen(product: product),
                      ),
                    ),
                    child: _buildBannerCard(context, product),
                  );
                },
                options: CarouselOptions(
                  height: 180,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 5),
                  autoPlayCurve: Curves.easeInOutCubic,
                  enlargeCenterPage: true,
                  enlargeFactor: 0.2,
                  viewportFraction: 0.88,
                  onPageChanged: (index, reason) {
                    setState(() => _currentBanner = index);
                  },
                ),
              ),
              // Dot indicators
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(featuredProducts.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentBanner == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentBanner == index
                          ? colorScheme.primary
                          : colorScheme.primary.withAlpha(51),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),

        // ── Category Section ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: const SectionHeader(
              title: 'Danh mục',
              subtitle: 'Khám phá theo loại sản phẩm',
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Nếu màn hình nhỏ (ví dụ dưới 500px), cho xuống dòng (Wrap)
                if (constraints.maxWidth < 900) {
                  return Wrap(
                    spacing: 8,
                    runSpacing: 10,
                    children: _buildAllCategoryChips(),
                  );
                } else {
                  // Nếu màn hình lớn, cho vuốt ngang
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: _buildAllCategoryChips().map((chip) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: chip,
                        );
                      }).toList(),
                    ),
                  );
                }
              },
            ),
          ),
        ),

        // ── Products Section ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
            child: SectionHeader(
              title: 'Sản phẩm',
              subtitle: '${_filteredProducts.length} sản phẩm',
              trailing: 'Xem tất cả',
            ),
          ),
        ),

        // ── Product Grid ──
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          sliver: _filteredProducts.isNotEmpty
              ? SliverGrid.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    return ProductCard(
                      product: product,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetailScreen(product: product),
                        ),
                      ),
                      onAddToCart: () {
                        CartManager.addProduct(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Đã thêm ${product.name}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                )
              : SliverGrid.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return Shimmer.fromColors(
                      baseColor: colorScheme.surfaceContainerLow,
                      highlightColor: colorScheme.surfaceContainerLowest,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  List<Widget> _buildAllCategoryChips() {
    return [
      // "All" Category
      _buildCategoryChip(
        label: 'Tất cả',
        icon: Icons.apps_rounded,
        isSelected: _selectedCategory < 0,
        onTap: () => _onCategorySelected(-1),
      ),
      // Other Categories
      ...List.generate(mockCategories.length, (index) {
        final category = mockCategories[index];
        return _buildCategoryChip(
          label: category.title,
          icon: category.icon,
          isSelected: index == _selectedCategory,
          onTap: () => _onCategorySelected(index),
        );
      }),
    ];
  }

  Widget _buildBannerCard(BuildContext context, Product product) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0077ED), Color(0xFF5856D6)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0077ED).withAlpha(51),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(20),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(13),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(38),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Nổi bật',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '\$${product.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.white.withAlpha(204),
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: product.imageUrl.startsWith('http')
                      ? Image.network(
                          product.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.image_outlined,
                            color: Colors.white.withAlpha(128),
                          ),
                        )
                      : Image.asset(
                          product.imageUrl,
                          fit: BoxFit.contain,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant.withAlpha(100),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : colorScheme.onSurface.withAlpha(153),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : colorScheme.onSurface.withAlpha(179),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
