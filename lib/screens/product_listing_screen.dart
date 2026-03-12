import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../providers/cart_provider.dart';
import '../screens/cart_screen.dart';

class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({super.key});

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductProvider>();

      if (!provider.hasData) {
        provider.loadProducts().then((_) {
          if (mounted) _fadeController.forward();
        });
      } else {
        _fadeController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF2F2F7),
              Color(0xFFE9ECF2),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Consumer<ProductProvider>(
          builder: (context, provider, _) {
            return Scrollbar(
              radius: const Radius.circular(10),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  _IOSLargeTitleAppBar(provider: provider),
                  if (provider.isLoading)
                    const SliverFillRemaining(child: _LoadingState())
                  else if (provider.hasError)
                    SliverFillRemaining(
                      child: _ErrorState(
                        message: provider.errorMessage,
                        onRetry: provider.loadProducts,
                      ),
                    )
                  else if (!provider.hasData)
                    const SliverFillRemaining(child: SizedBox())
                  else if (provider.products.isEmpty)
                    const SliverFillRemaining(child: _EmptyState())
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      sliver: _AnimatedProductGrid(
                        products: provider.products,
                        animation: _fadeAnimation,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _IOSLargeTitleAppBar extends StatelessWidget {
  final ProductProvider provider;

  const _IOSLargeTitleAppBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      stretch: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: _AppBarBackground(provider: provider),
      ),
    );
  }
}

class _AppBarBackground extends StatelessWidget {
  final ProductProvider provider;

  const _AppBarBackground({required this.provider});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.only(top: 56),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            border: Border(
              bottom: BorderSide(
                color: Colors.black.withOpacity(0.05),
              ),
            ),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "ShopEasy",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Discover what's trending today",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _SearchBar(),
                  const SizedBox(height: 12),
                  if (provider.hasData) _CategoryPills(provider: provider),
                ],
              ),

              /// CART ICON
              Positioned(
                top: 10,
                right: 10,
                child: Consumer<CartProvider>(
                  builder: (context, cart, _) {
                    return Stack(
                      children: [
                        IconButton(
                          icon: const Icon(
                            CupertinoIcons.cart,
                            color: Color(0xFF1C1C1E),
                            size: 28,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CartScreen(),
                              ),
                            );
                          },
                        ),
                        if (cart.totalItems > 0)
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                cart.totalItems.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CupertinoSearchTextField(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),

        /// SEARCH LISTENER
        onChanged: (value) {
          context.read<ProductProvider>().searchProducts(value);
        },
      ),
    );
  }
}

class _CategoryPills extends StatelessWidget {
  final ProductProvider provider;

  const _CategoryPills({required this.provider});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: provider.categories.length,
        itemBuilder: (context, index) {
          final category = provider.categories[index];
          final isSelected = provider.selectedCategory == category;

          return _PillChip(
            label: category[0].toUpperCase() + category.substring(1),
            isSelected: isSelected,
            onTap: () => provider.setCategory(category),
          );
        },
      ),
    );
  }
}

class _PillChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PillChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1C1C1E)
              : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.black.withOpacity(0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF3A3A3C),
          ),
        ),
      ),
    );
  }
}

class _AnimatedProductGrid extends StatelessWidget {
  final List products;
  final Animation<double> animation;

  const _AnimatedProductGrid({
    required this.products,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              final delay = (index * 0.06).clamp(0.0, 0.5);

              final value =
                  ((animation.value - delay) / (1 - delay)).clamp(0.0, 1.0);

              return Opacity(
                opacity: value,
                child: Transform.scale(
                  scale: 0.95 + (value * 0.05),
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                ),
              );
            },
            child: ProductCard(product: products[index]),
          );
        },
        childCount: products.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 14,
        mainAxisSpacing: 16,
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoActivityIndicator(radius: 14),
          SizedBox(height: 16),
          Text(
            "Loading products...",
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF8E8E93),
            ),
          )
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CupertinoButton.filled(
        onPressed: onRetry,
        child: const Text("Retry"),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "No Products Found",
        style: TextStyle(
          fontSize: 18,
          color: Color(0xFF8E8E93),
        ),
      ),
    );
  }
}
