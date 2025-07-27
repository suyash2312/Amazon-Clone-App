import 'package:amazon_clone_app/common/widgets/loader.dart';
import 'package:amazon_clone_app/constants/global_variables.dart';
import 'package:amazon_clone_app/features/account/services/account_services.dart';
import 'package:amazon_clone_app/features/account/widgets/single_product.dart';
import 'package:amazon_clone_app/features/order_details/screens/order_details.dart';
import 'package:amazon_clone_app/models/order.dart';
import 'package:flutter/material.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  List<Order>? orders;
  List<Order> validOrders = []; // Orders with at least one product
  final AccountServices accountServices = AccountServices();

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  void fetchOrders() async {
    orders = await accountServices.fetchMyOrders(context: context);

    if (!mounted) return;

    validOrders = orders!.where((order) => order.products.isNotEmpty).toList();

    for (int i = 0; i < orders!.length; i++) {
      debugPrint("Order $i has ${orders![i].products.length} products");
      if (orders![i].products.isNotEmpty) {
        debugPrint(
          "First product has ${orders![i].products[0].images.length} images",
        );
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return orders == null
        ? const Loader()
        : validOrders.isEmpty
        ? const Center(child: Text("No valid orders found."))
        : Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 15),
                    child: const Text(
                      'Your Orders',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(right: 15),
                    child: Text(
                      'See all',
                      style: TextStyle(
                        color: GlobalVariables.selectedNavBarColor,
                      ),
                    ),
                  ),
                ],
              ),
              // Display orders
              Container(
                height: 170,
                padding: const EdgeInsets.only(left: 10, top: 20, right: 0),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: validOrders.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          OrderDetailScreen.routeName,
                          arguments: validOrders[index],
                        );
                      },
                      child: SingleProduct(
                        image: validOrders[index].products[0].images[0],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
  }
}
