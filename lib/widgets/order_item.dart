import 'package:flutter/material.dart';
import 'package:shop_app/providers/orders_provider.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class OrderItem extends StatefulWidget {
  final OrderModel order;

  OrderItem(this.order);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text('\$${widget.order.amount}'),
            subtitle: Text(
              DateFormat('dd/MM/yyyy hh:mm').format(widget.order.dateTime),
            ),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeIn,
            height: !_expanded
                ? 0
                : min(widget.order.products.length * 20.0 + 40.0, 180.0),
            child: ListView(
                padding: EdgeInsets.all(16),
                children: widget.order.products
                    .map(
                      (prod) => Container(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              prod.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${prod.quantity} x \$${prod.price}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                    .toList()),
          ),
        ],
      ),
    );
  }
}
