import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/order_item.dart';

import '../providers/orders_provider.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  @override
  Widget build(BuildContext context) {
    //final orderData = Provider.of<OrderProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Your orders'),
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
          future: Provider.of<OrderProvider>(context, listen: false)
              .fetchAndSetOrders(),
          builder: (ctx, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (dataSnapshot.error != null) {
              return Center(
                child: Text('An error occured!'),
              );
            } else {
              return Consumer<OrderProvider>(
                builder: (ctx, orderData, child) => ListView.builder(
                  itemCount: orderData.orders.length,
                  itemBuilder: (context, index) =>
                      OrderItem(orderData.orders[index]),
                ),
              );
            }
          },
        ));
  }
}
