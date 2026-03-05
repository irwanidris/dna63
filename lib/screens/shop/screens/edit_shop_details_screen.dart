import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/woo_commerce/billing_address_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/shop/components/billing_address_component.dart';
import 'package:socialv/store/shop_store.dart';
import 'package:socialv/utils/app_constants.dart';

class EditShopDetailsScreen extends StatefulWidget {
  const EditShopDetailsScreen({Key? key}) : super(key: key);

  @override
  State<EditShopDetailsScreen> createState() => _EditShopDetailsScreenState();
}

class _EditShopDetailsScreenState extends State<EditShopDetailsScreen> {
  ShopStore editShopDetailsScreenVars = ShopStore();

  @override
  void initState() {
    super.initState();

    init();
  }

  Future<void> init() async {
    appStore.setLoading(true);
    await getCustomer().then((value) {
      shopStore.billingAddress = value.billing!;
      shopStore.shippingAddress = value.shipping!;
      getCountries().then((value) {
        shopStore.countriesList.addAll(value);
        appStore.setLoading(false);
      }).catchError((e) {
        appStore.setLoading(false);
        log('e.toString(): ${e.toString()}');
      });
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  @override
  void dispose() {
    appStore.setLoading(false);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(language.editBillingDetails, style: boldTextStyle(size: 20)),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.iconColor),
            onPressed: () {
              finish(context, true);
            },
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Observer(builder: (context) {
                      return ExpansionTile(
                        initiallyExpanded: true,
                        title: Text(language.billingAddress, style: boldTextStyle()),
                        children: <Widget>[
                          BillingAddressComponent(
                            data: shopStore.billingAddress,
                            isBilling: true,
                            formKey: editShopDetailsScreenVars.formKey,
                          ),
                        ],
                        backgroundColor: context.cardColor,
                        collapsedBackgroundColor: context.cardColor,
                        iconColor: appStore.isDarkMode ? bodyDark : bodyWhite,
                        childrenPadding: EdgeInsets.symmetric(horizontal: 16),
                      );
                    }),
                    16.height,
                    Row(
                      children: [
                        Observer(builder: (context) {
                          return Checkbox(
                            shape: RoundedRectangleBorder(borderRadius: radius(4)),
                            activeColor: context.primaryColor,
                            side: BorderSide(color: context.primaryColor),
                            value: editShopDetailsScreenVars.isSameShippingAddress,
                            onChanged: (val) {
                              editShopDetailsScreenVars.isSameShippingAddress = val.validate();
                              if (val.validate()) {
                                shopStore.shippingAddress = shopStore.billingAddress;
                                // Trigger expansion when checkbox is checked
                                editShopDetailsScreenVars.shippingTileExpanded = true;
                              } else {
                                shopStore.shippingAddress = BillingAddressModel();
                              }
                            },
                          );
                        }),
                        GestureDetector(
                          onTap: () {
                            editShopDetailsScreenVars.isSameShippingAddress = !editShopDetailsScreenVars.isSameShippingAddress;

                            if (editShopDetailsScreenVars.isSameShippingAddress) {
                              shopStore.shippingAddress = shopStore.billingAddress;
                              // Trigger expansion when checkbox is checked via tap
                              editShopDetailsScreenVars.shippingTileExpanded = true;
                            } else {
                              shopStore.shippingAddress = BillingAddressModel();
                            }
                          },
                          child: Text(language.billingAndShippingAddresses, style: secondaryTextStyle()),
                        ),
                      ],
                    ),
                    16.height,
                    Observer(builder: (context) {
                      return ExpansionTile(
                        key: Key(editShopDetailsScreenVars.shippingTileExpanded.toString()), // Force rebuild when state changes
                        initiallyExpanded: editShopDetailsScreenVars.shippingTileExpanded,
                        childrenPadding: EdgeInsets.symmetric(horizontal: 16),
                        backgroundColor: context.cardColor,
                        collapsedBackgroundColor: context.cardColor,
                        iconColor: appStore.isDarkMode ? bodyDark : bodyWhite,
                        title: Text(language.shippingAddress, style: boldTextStyle()),
                        children: <Widget>[
                          BillingAddressComponent(
                            data: shopStore.shippingAddress,
                            formKey: editShopDetailsScreenVars.formKey,
                          ),
                        ],
                        onExpansionChanged: (expanded) {
                          editShopDetailsScreenVars.shippingTileExpanded = expanded;
                        },
                      );
                    }),
                  ],
                ),
              ),
              Observer(builder: (_) => LoadingWidget().center().visible(appStore.isLoading))
            ],
          ),
        ),
        bottomNavigationBar: Observer(
          builder: (_) => appButton(
              context: context,
              text: language.update,
              onTap: () async {
                if (editShopDetailsScreenVars.formKey.currentState?.validate() ?? false) {
                  appStore.setLoading(true);
                  Map request = {"billing": shopStore.billingAddress, "shipping": shopStore.shippingAddress};
                  updateCustomer(request: request).then((value) {
                    toast(language.updatedSuccessfully, print: true);
                    finish(context, true);
                    appStore.setLoading(false);
                  }).catchError(
                    (e) {
                      appStore.setLoading(false);
                      if (e.toString() == "Invalid parameter(s): billing") {
                        toast(language.enterValidDetails);
                      } else {
                        log(e.toString());
                        toast(language.somethingWentWrong, print: true);
                      }
                    },
                  );
                }
              }).paddingAll(16).visible(!appStore.isLoading),
        ));
  }
}
