import 'package:flutter/material.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';

class CartItem extends StatelessWidget {
  final CartModel cartItem;

  CartItem(this.cartItem);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(cartItem.id),
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          size: 40,
          color: Colors.white,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 16),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text('Are you sure?'),
                content: Text('Do you want to remove the item from the cart?'),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(ctx).pop(false);
                    },
                    child: Text('NO'),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.of(ctx).pop(true);
                    },
                    child: Text('YES'),
                  ),
                ],
              );
            });
      },
      onDismissed: (direction) {
        Provider.of<CartProvider>(context, listen: false)
            .removeItem(cartItem.productID);
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: FittedBox(
                  child: Text('\$${cartItem.price}'),
                ),
              ),
            ),
            title: Text(cartItem.title),
            subtitle: Text('Total: \$${cartItem.price * cartItem.quantity}'),
            trailing: Text('${cartItem.quantity} x'),
          ),
        ),
      ),
    );
  }
}
