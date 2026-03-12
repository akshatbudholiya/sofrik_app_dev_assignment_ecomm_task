import 'dart:ui';
import 'package:ecommerce_app/screens/cart_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _HeroAppBar(product: product),
              SliverToBoxAdapter(
                child: _ProductContent(product: product),
              )
            ],
          ),
          _AddToCartBar(product: product),
        ],
      ),
    );
  }
}

class _HeroAppBar extends StatelessWidget {
  final Product product;

  const _HeroAppBar({required this.product});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 360,
      pinned: true,
      backgroundColor: Colors.white.withOpacity(0.8),
      leading: IconButton(
        icon: const Icon(CupertinoIcons.back, color: Color(0xFF1C1C1E)),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Container(
              color: Colors.white,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Hero(
                    tag: product.id,
                    child: CachedNetworkImage(
                      imageUrl: product.image,
                      fit: BoxFit.contain,
                      placeholder: (_, __) =>
                          const CupertinoActivityIndicator(),
                    ),
                  ),
                ),
              ),
            ),

            /// blur overlay
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                child: Container(color: Colors.transparent),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _ProductContent extends StatelessWidget {
  final Product product;

  const _ProductContent({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// category
          Text(
            product.category.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              letterSpacing: 1.2,
              color: Color(0xFF8E8E93),
            ),
          ),

          const SizedBox(height: 6),

          /// title
          Text(
            product.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: Color(0xFF1C1C1E),
            ),
          ),

          const SizedBox(height: 14),

          /// rating
          Row(
            children: [
              RatingBarIndicator(
                rating: product.rating.rate,
                itemBuilder: (context, _) =>
                    const Icon(Icons.star_rounded, color: Colors.amber),
                itemCount: 5,
                itemSize: 18,
              ),
              const SizedBox(width: 8),
              Text(
                "${product.rating.rate} (${product.rating.count} reviews)",
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8E8E93),
                ),
              )
            ],
          ),

          const SizedBox(height: 24),

          /// price card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.tag_fill,
                  color: Color(0xFF34C759),
                ),
                const SizedBox(width: 10),
                Text(
                  "₹ ${product.price.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          /// description
          const Text(
            "Description",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            product.description,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Color(0xFF3A3A3C),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddToCartBar extends StatelessWidget {
  final Product product;

  const _AddToCartBar({required this.product});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final inCart = cartProvider.containsProduct(product.id);
    final quantity = cartProvider.quantityOf(product.id);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: SafeArea(
          top: false,
          child: inCart
              ? Row(
                  children: [
                    _QuantitySelector(
                      quantity: quantity,
                      onAdd: () => cartProvider.increaseQuantity(product.id),
                      onRemove: () => cartProvider.decreaseQuantity(product.id),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: CupertinoButton.filled(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CartScreen(),
                            ),
                          );
                        },
                        child: const Text("View Cart"),
                      ),
                    )
                  ],
                )
              : SizedBox(
                  width: double.infinity,
                  child: CupertinoButton.filled(
                    onPressed: () {
                      cartProvider.addToCart(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Added to cart"),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: const Text("Add to Cart"),
                  ),
                ),
        ),
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _QuantitySelector({
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD1D1D6)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(CupertinoIcons.minus),
            onPressed: onRemove,
          ),
          Text(
            "$quantity",
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.plus),
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}
