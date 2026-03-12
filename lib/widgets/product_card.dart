import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../screens/product_detail_screen.dart';

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.05,
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 0.96).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final cartProvider = context.watch<CartProvider>();
    final inCart = cartProvider.containsProduct(product.id);

    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) => _pressController.reverse(),
      onTapCancel: () => _pressController.reverse(),
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: AnimatedBuilder(
        animation: _pressController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [
                Colors.white,
                Color(0xFFF7F7FA),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// IMAGE AREA
                Expanded(
                  flex: 6,
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF6F6F8),
                        ),
                        child: Hero(
                          tag: product.id,
                          child: CachedNetworkImage(
                            imageUrl: product.image,
                            fit: BoxFit.contain,
                            placeholder: (_, __) => const Center(
                              child: CupertinoActivityIndicator(),
                            ),
                            errorWidget: (_, __, ___) => const Icon(
                              CupertinoIcons.photo,
                              size: 40,
                              color: Color(0xFFD1D1D6),
                            ),
                          ),
                        ),
                      ),

                      /// RATING BADGE
                      Positioned(
                        left: 10,
                        top: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                CupertinoIcons.star_fill,
                                size: 12,
                                color: Color(0xFFFFCC00),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                product.rating.rate.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),

                      /// CART BUTTON
                      Positioned(
                        top: 10,
                        right: 10,
                        child: _CartBadge(
                          inCart: inCart,
                          onTap: () {
                            if (!inCart) {
                              cartProvider.addToCart(product);
                              _showAddedFeedback(context);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                /// INFO AREA
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),

                        /// PRICE
                        Text(
                          '₹ ${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddedFeedback(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(CupertinoIcons.check_mark_circled_solid,
                color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              "Added to cart",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1C1C1E),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _CartBadge extends StatelessWidget {
  final bool inCart;
  final VoidCallback onTap;

  const _CartBadge({required this.inCart, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: inCart ? const Color(0xFF34C759) : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Icon(
          inCart ? CupertinoIcons.checkmark_alt : CupertinoIcons.plus,
          size: 17,
          color: inCart ? Colors.white : const Color(0xFF1C1C1E),
        ),
      ),
    );
  }
}