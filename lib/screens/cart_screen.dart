import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../widgets/cart_item_tile.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _PremiumAppBar(cart: cart),

              cart.isEmpty
                  ? const SliverFillRemaining(
                      child: _EmptyCartState(),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) =>
                              CartItemTile(item: cart.items[index]),
                          childCount: cart.items.length,
                        ),
                      ),
                    ),
            ],
          );
        },
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cart, _) =>
            cart.isEmpty ? const SizedBox() : _OrderSummary(cart: cart),
      ),
    );
  }
}

class _PremiumAppBar extends StatelessWidget {
  final CartProvider cart;

  const _PremiumAppBar({required this.cart});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 80,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white.withOpacity(0.9),
      leading: IconButton(
        icon: const Icon(CupertinoIcons.back, color: Color(0xFF1C1C1E)),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(color: Colors.white.withOpacity(0.7)),
        ),
      ),
      title: const Text(
        "My Cart",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1C1C1E),
        ),
      ),
      actions: [
        if (!cart.isEmpty)
          IconButton(
            icon: const Icon(
              CupertinoIcons.trash,
              color: Colors.red,
            ),
            onPressed: () => _confirmClearCart(context, cart),
          ),
      ],
    );
  }

  Future<void> _confirmClearCart(
      BuildContext context, CartProvider cart) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text("Clear Cart"),
        content:
            const Text("Are you sure you want to remove all items?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text("Clear"),
          ),
        ],
      ),
    );

    if (confirmed == true) cart.clearCart();
  }
}

class _EmptyCartState extends StatelessWidget {
  const _EmptyCartState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.cart,
              size: 90,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 20),
            const Text(
              "Your cart is empty",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Add products to start shopping",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8E8E93),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final CartProvider cart;

  const _OrderSummary({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${cart.totalItems} item${cart.totalItems > 1 ? 's' : ''}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8E8E93),
                  ),
                ),
                Text(
                  "₹ ${cart.totalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6C63FF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton.filled(
                onPressed: () => _showCheckoutConfirmation(context, cart),
                child: const Text("Checkout"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCheckoutConfirmation(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(CupertinoIcons.check_mark_circled,
                color: Colors.green),
            SizedBox(width: 8),
            Text("Order Placed"),
          ],
        ),
        content: Text(
          "${cart.totalItems} item${cart.totalItems > 1 ? 's' : ''}\n\n"
          "Total: ₹ ${cart.totalPrice.toStringAsFixed(2)}\n\n"
          "Your order is being processed.",
        ),
        actions: [
          CupertinoButton(
            child: const Text("Done"),
            onPressed: () {
              cart.clearCart();
              Navigator.pop(ctx);
            },
          )
        ],
      ),
    );
  }
}