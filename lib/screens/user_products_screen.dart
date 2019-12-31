import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/user_product_item.dart';

import '../providers/products_provider.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<ProductsProvider>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your products'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          )
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            return RefreshIndicator(
              onRefresh: () {
                return _refreshProducts(context);
              },
              child: Consumer<ProductsProvider>(
                builder: (ctx, productsData, _) {
                  return Padding(
                    padding: EdgeInsets.all(8),
                    child: ListView.builder(
                      itemCount: productsData.items.length,
                      itemBuilder: (ctx, index) => Column(
                        children: [
                          UserProductItem(
                            id: productsData.items[index].id,
                            title: productsData.items[index].title,
                            imageUrl: productsData.items[index].imageUrl,
                          ),
                          Divider(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
