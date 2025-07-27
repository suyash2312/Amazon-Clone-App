import 'package:amazon_clone_app/constants/utils.dart';
import 'package:amazon_clone_app/features/address/services/address_services.dart';
import 'package:flutter/material.dart';
import 'package:pay/pay.dart';
import 'package:provider/provider.dart';
import 'package:amazon_clone_app/common/widgets/custom_textfield.dart';
import 'package:amazon_clone_app/constants/global_variables.dart';
import 'package:amazon_clone_app/providers/user_provider.dart';

class AddressScreen extends StatefulWidget {
  static const String routeName = '/address';
  final String totalAmount;
  const AddressScreen({Key? key, required this.totalAmount}) : super(key: key);

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final TextEditingController flatBuildingController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final _addressFormKey = GlobalKey<FormState>();

  String addressToBeUsed = "";
  late List<PaymentItem> paymentItems;
  final AddressServices addressServices = AddressServices();

  @override
  void initState() {
    super.initState();
    paymentItems = [
      PaymentItem(
        amount: widget.totalAmount,
        label: 'Total Amount',
        status: PaymentItemStatus.final_price,
      ),
    ];
  }

  @override
  void dispose() {
    flatBuildingController.dispose();
    areaController.dispose();
    pincodeController.dispose();
    cityController.dispose();
    super.dispose();
  }

  void onApplePayResult(Map<String, dynamic> res) {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user.address.isEmpty) {
      addressServices.saveUserAddress(
        context: context,
        address: addressToBeUsed,
      );
    }
    addressServices.placeOrder(
      context: context,
      address: addressToBeUsed,
      totalSum: double.parse(widget.totalAmount),
    );
  }

  void onGooglePayResult(Map<String, dynamic> res) {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user.address.isEmpty) {
      addressServices.saveUserAddress(
        context: context,
        address: addressToBeUsed,
      );
    }
    addressServices.placeOrder(
      context: context,
      address: addressToBeUsed,
      totalSum: double.parse(widget.totalAmount),
    );
  }

  void payPressed(String addressFromProvider) {
    addressToBeUsed = "";
    final isFormFilled =
        flatBuildingController.text.isNotEmpty ||
        areaController.text.isNotEmpty ||
        pincodeController.text.isNotEmpty ||
        cityController.text.isNotEmpty;

    if (isFormFilled) {
      if (_addressFormKey.currentState!.validate()) {
        addressToBeUsed =
            '${flatBuildingController.text}, ${areaController.text}, ${cityController.text} - ${pincodeController.text}';
      } else {
        showSnackBar(context, 'Please fill all the fields correctly');
        return;
      }
    } else if (addressFromProvider.isNotEmpty) {
      addressToBeUsed = addressFromProvider;
    } else {
      showSnackBar(context, 'Please provide an address');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final address = context.watch<UserProvider>().user.address;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: GlobalVariables.appBarGradient,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              if (address.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Text(address, style: const TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 20),
                const Text('OR', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
              ],
              Form(
                key: _addressFormKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: flatBuildingController,
                      hintText: 'Flat, House no, Building',
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: areaController,
                      hintText: 'Area, Street',
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: pincodeController,
                      hintText: 'Pincode',
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: cityController,
                      hintText: 'Town/City',
                    ),
                  ],
                ),
              ),

              FutureBuilder<PaymentConfiguration>(
                future: PaymentConfiguration.fromAsset('applepay.json'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    return ApplePayButton(
                      paymentConfiguration: snapshot.data!,
                      paymentItems: paymentItems,
                      style: ApplePayButtonStyle.whiteOutline,
                      type: ApplePayButtonType.buy,
                      margin: const EdgeInsets.only(top: 15),
                      height: 50,
                      width: double.infinity,
                      onPressed: () => payPressed(address),
                      onPaymentResult: onApplePayResult,
                      loadingIndicator: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return const SizedBox(height: 50); // placeholder
                },
              ),
              const SizedBox(height: 10),

              FutureBuilder<PaymentConfiguration>(
                future: PaymentConfiguration.fromAsset('gpay.json'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    return GooglePayButton(
                      paymentConfiguration: snapshot.data!,
                      paymentItems: paymentItems,
                      theme: GooglePayButtonTheme.dark,
                      type: GooglePayButtonType.buy,
                      margin: const EdgeInsets.only(top: 15),
                      height: 50,
                      onPressed: () => payPressed(address),
                      onPaymentResult: onGooglePayResult,
                      loadingIndicator: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return const SizedBox(height: 50);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
