import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/cart_item.dart';
import '../providers/cart_provider.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;

  const CartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.read<CartProvider>();

    return Dismissible(
      key: ValueKey(item.product.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(
          CupertinoIcons.delete,
          color: Colors.white,
          size: 26,
        ),
      ),
      onDismissed: (_) =>
          cartProvider.removeFromCart(item.product.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Row(
          children: [
            _ProductThumbnail(imageUrl: item.product.image),

            const SizedBox(width: 14),

            /// PRODUCT INFO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// TITLE
                  Text(
                    item.product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      height: 1.3,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// PRICE PER ITEM
                  Text(
                    "₹ ${item.product.price.toStringAsFixed(2)} each",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8E8E93),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [

                      /// QUANTITY
                      _QuantityControl(item: item),

                      const Spacer(),

                      /// TOTAL PRICE
                      FittedBox(
                        child: Text(
                          "₹${item.lineTotal.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Color(0xFF6C63FF),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductThumbnail extends StatelessWidget {
  final String imageUrl;

  const _ProductThumbnail({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 85,
      height: 85,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.contain,
        placeholder: (_, __) =>
            const CupertinoActivityIndicator(),
        errorWidget: (_, __, ___) =>
            const Icon(Icons.broken_image),
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  final CartItem item;

  const _QuantityControl({required this.item});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.read<CartProvider>();

    return Container(
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD1D1D6)),
      ),
      child: Row(
        children: [

          /// MINUS
          IconButton(
            icon: Icon(
              item.quantity == 1
                  ? CupertinoIcons.delete
                  : CupertinoIcons.minus,
              size: 18,
              color: item.quantity == 1
                  ? Colors.redAccent
                  : const Color(0xFF6C63FF),
            ),
            onPressed: () =>
                cartProvider.decreaseQuantity(item.product.id),
          ),

          /// QTY
          Text(
            "${item.quantity}",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),

          /// PLUS
          IconButton(
            icon: const Icon(
              CupertinoIcons.plus,
              size: 18,
              color: Color(0xFF6C63FF),
            ),
            onPressed: () =>
                cartProvider.increaseQuantity(item.product.id),
          ),
        ],
      ),
    );
  }
}