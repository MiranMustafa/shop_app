import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments as String;
    final loadedProduct = Provider.of<ProductsProvider>(
      context,
      listen: false,
    ).findById(productId);

    return Scaffold(
//      appBar: AppBar(
//        title: Text(loadedProduct.title),
//      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(loadedProduct.title),
              background: Hero(
                tag: productId,
                child: Image.network(
                  loadedProduct.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                SizedBox(height: 8),
                Text(
                  '\$${loadedProduct.price}',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    loadedProduct.description,
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
