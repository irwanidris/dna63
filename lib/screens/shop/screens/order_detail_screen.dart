import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/woo_commerce/order_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/shop/components/price_widget.dart';
import 'package:socialv/screens/shop/screens/edit_shop_details_screen.dart';
import 'package:socialv/store/shop_store.dart';
import 'package:socialv/utils/cached_network_image.dart';

import '../../../utils/app_constants.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel orderDetails;
  final VoidCallback? onCancel;

  const OrderDetailScreen({required this.orderDetails, this.onCancel});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  ShopStore orderDetailScreenVars = ShopStore();
  double subtotal = 0;

  @override
  void initState() {
    getSubTotal();
    getBillingDetails();
    orderDetailScreenVars.orderStatus = widget.orderDetails.status.validate().capitalizeFirstLetter();
    super.initState();
  }

  getBillingDetails() async {
    await getCustomer().then((value) {
      shopStore.billingAddress = value.billing!;
      //shopStore.shippingAddress = value.billing!;
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

  Future<void> onDeleteOrder() async {
    showConfirmDialogCustom(
      context,
      onAccept: (c) {
        ifNotTester(() {
          appStore.setLoading(true);
          deleteOrder(orderId: widget.orderDetails.id.validate()).then((value) {
            toast(language.orderDeletedSuccessfully);
            appStore.setLoading(false);
            finish(context, true);
          }).catchError((e) {
            appStore.setLoading(false);
            toast(e.toString(), print: true);
          });
        });
      },
      dialogType: DialogType.CONFIRMATION,
      title: language.deleteOrderConfirmation,
      positiveText: language.yes,
      negativeText: language.no,
    );
  }

  Future<void> downloadOrderInvoice() async {
    try {
      String orderId = widget.orderDetails.id.validate().toString();

      final File? invoiceFile = await InvoiceDownloader.downloadInvoice(
        type: InvoiceType.order,
        params: {
          'orderId': orderId,
        },
      );

      if (invoiceFile != null) {
        print('Invoice downloaded to: ${invoiceFile.path}');
        toast(language.invoiceDownloadedSuccessfully);
      } else {
        toast(language.failedInvoiceDownload);
      }
    } catch (e) {
      toast("Error: $e");
    }
  }

  void getSubTotal() {
    widget.orderDetails.lineItems.validate().forEach((element) {
      subtotal = subtotal + element.subtotal.toDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          finish(context, orderDetailScreenVars.isChange);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.iconColor),
            onPressed: () {
              finish(context, orderDetailScreenVars.isChange);
            },
          ),
          titleSpacing: 0,
          title: Text(language.orderDetails, style: boldTextStyle(size: 22)),
          elevation: 0,
          centerTitle: true,
          actions: [
            Theme(
              data: Theme.of(context).copyWith(),
              child: PopupMenuButton(
                enabled: !appStore.isLoading,
                position: PopupMenuPosition.under,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(commonRadius)),
                onSelected: (val) async {
                  if (val == 1) {
                    onDeleteOrder();
                  } else {
                    widget.onCancel!.call();
                  }
                },
                icon: Icon(Icons.more_horiz),
                itemBuilder: (context) => <PopupMenuEntry>[
                  /* PopupMenuItem(
                    value: 1,
                    child: Row(
                      children: [
                        Image.asset(ic_delete, width: 20, height: 20, color: Colors.red, fit: BoxFit.cover),
                        8.width,
                        Text(language.deleteOrder, style: primaryTextStyle()),
                      ],
                    ),
                  ),*/
                  if (widget.orderDetails.status.validate() != OrderStatus.cancelled &&
                      widget.orderDetails.status.validate() != OrderStatus.refunded &&
                      widget.orderDetails.status.validate() != OrderStatus.completed &&
                      widget.orderDetails.status.validate() != OrderStatus.trash &&
                      widget.orderDetails.status.validate() != OrderStatus.failed)
                    PopupMenuItem(
                      value: 2,
                      child: Row(
                        children: [
                          Image.asset(ic_close_square, width: 20, height: 20, color: Colors.red, fit: BoxFit.cover),
                          8.width,
                          Text(language.cancelOrder, style: primaryTextStyle()),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// ORDER STATUS
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: radius(16)),
                      child: ListTile(
                        leading: Icon(Icons.local_shipping, color: context.primaryColor),
                        title: Text(language.orderStatus, style: boldTextStyle()),
                        trailing: Text(orderDetailScreenVars.orderStatus, style: boldTextStyle(color: context.primaryColor, size: 18)),
                      ),
                    ),
                    16.height,

                    /// ORDER INFO
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: radius(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _orderInfoRow(Icons.confirmation_number, language.orderNumber, widget.orderDetails.id.toString()),
                            12.height,
                            _orderInfoRow(Icons.calendar_today, language.date, formatDate(widget.orderDetails.dateCreated.validate().toString())),
                            12.height,
                            _orderInfoRow(Icons.credit_card, language.paymentMethod, widget.orderDetails.paymentMethodTitle!.capitalizeFirstLetter()),
                          ],
                        ),
                      ),
                    ),
                    16.height,

                    /// PRICE DETAILS
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: radius(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(language.priceDetails, style: boldTextStyle()),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    downloadOrderInvoice();
                                  },
                                  icon: const Icon(Icons.download, size: 18),
                                  label: Text(language.invoice),
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: radius(8)),
                                    backgroundColor: context.primaryColor,
                                    foregroundColor: Colors.white,
                                  ),
                                ).visible(widget.orderDetails.status == 'completed'),
                              ],
                            ),
                            12.height,
                            Divider(),
                            _priceRow(language.subTotal, subtotal.toString()),
                            if (widget.orderDetails.discountTotal != '0.00') _priceRow(language.discount, "- ${widget.orderDetails.discountTotal}"),
                            Divider(),
                            _priceRow(language.total, widget.orderDetails.total.toString(), isTotal: true),
                          ],
                        ),
                      ),
                    ),
                    16.height,

                    /// ITEMS LIST
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: radius(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(language.orderDetails, style: boldTextStyle()),
                            12.height,
                            ListView.separated(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: widget.orderDetails.lineItems!.length,
                              separatorBuilder: (_, __) => Divider(),
                              itemBuilder: (ctx, index) {
                                final item = widget.orderDetails.lineItems![index];
                                return Row(
                                  children: [
                                    cachedImage(item.image!.src.validate(), height: 40, width: 40, fit: BoxFit.cover).cornerRadiusWithClipRRect(8),
                                    12.width,
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.name.validate(), style: primaryTextStyle()),
                                        Text("x${item.quantity}", style: secondaryTextStyle(size: 12)),
                                      ],
                                    ).expand(),
                                    PriceWidget(
                                      price: item.subtotal,
                                    )
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    16.height,

                    /// ORDER NOTE
                    if (widget.orderDetails.customerNote.validate().isNotEmpty)
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: radius(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(language.orderNote, style: boldTextStyle()),
                              12.height,
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.note_alt, size: 20, color: context.primaryColor),
                                  12.width,
                                  Text(
                                    widget.orderDetails.customerNote.validate(),
                                    style: primaryTextStyle(),
                                  ).expand(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    16.height,

                    /// SHIPPING INFO
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: radius(16)),
                      child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Observer(builder: (context) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(language.shippingAddress, style: boldTextStyle()),
                                    Image.asset(ic_edit, width: 18, height: 18, fit: BoxFit.cover, color: context.primaryColor).onTap(() {
                                      EditShopDetailsScreen().launch(context).then((value) {
                                        if (value ?? false) getBillingDetails();
                                      });
                                    }).visible(widget.orderDetails.status == 'pending' || widget.orderDetails.status == 'processing'),
                                  ],
                                ),
                                12.height,
                                _orderInfoRow(Icons.person, language.name, "${shopStore.billingAddress.firstName} ${shopStore.billingAddress.lastName}"),
                                // _orderInfoRow(Icons.business, "Company", widget.orderDetails.billing.company),
                                _orderInfoRow(
                                    Icons.location_on,
                                    language.address,
                                    "${shopStore.billingAddress.address_1}, ${shopStore.billingAddress.address_2}, ${shopStore.billingAddress.city},"
                                    " ${shopStore.billingAddress.country}"
                                    "${shopStore.billingAddress.state}"
                                    " "),
                                _orderInfoRow(Icons.phone, language.phone, shopStore.billingAddress.phone?.validate() ?? ""),
                              ],
                            );
                          })),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _orderInfoRow(IconData icon, String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        12.width,
        //Text("$title:", style: secondaryTextStyle()).expand(flex: 2),
        Text(value.isEmptyOrNull ? "-" : value, style: primaryTextStyle()).expand(flex: 3),
      ],
    ).paddingOnly(bottom: 8);
  }

  Widget _priceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: isTotal ? boldTextStyle(size: 16) : primaryTextStyle()),
        Text(value, style: isTotal ? boldTextStyle(size: 16, color: Colors.green) : primaryTextStyle()),
      ],
    );
  }
}
