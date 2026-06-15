import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/product.dart';
import 'package:bustedworld/core/utils/currency_formatter.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        // Allow the splash to match the beveled shape of the card
        customBorder: Theme.of(context).cardTheme.shape,
        onTap: () => context.push('/product/${product.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'image_${product.id}',
                    child: product.imageUrl.startsWith('data:image') 
                        ? Image.memory(
                            base64Decode(product.imageUrl.split(',').last),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(color: cs.surface),
                          )
                        : Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(color: cs.surface),
                          ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      color: cs.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Text(
                        formatRupiah(product.price),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: cs.outline, width: 1.5)),
              ),
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title.toUpperCase(),
                    style: tt.titleSmall?.copyWith(
                      fontSize: 13, 
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'VIEW DETAILS',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: cs.primary, size: 12),
                          const SizedBox(width: 4),
                          Text(
                             product.rating.toString(),
                             style: TextStyle(
                               color: cs.onSurfaceVariant,
                               fontSize: 10,
                               fontWeight: FontWeight.bold,
                             ),
                          ),
                        ],
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
  }
}
