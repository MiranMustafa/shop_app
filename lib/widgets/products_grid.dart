import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './product_item.dart';
import '../providers/product_provider.dart';
import '../providers/products_provider.dart';

class ProductsGrid extends StatelessWidget {
  final bool showOnlyFavorites;

  ProductsGrid(this.showOnlyFavorites);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductsProvider>(context);
    final products = showOnlyFavorites
        ? productsData.favItems
        : productsData.items;

    return GridView.builder(
      itemCount: products.length,
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        value: products[i],
        child: ProductItem(),
      ),
    );
  }
}

