import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/common_models.dart';
import 'package:socialv/models/woo_commerce/order_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/shop/components/cancel_order_bottomsheet.dart';
import 'package:socialv/screens/shop/components/price_widget.dart';
import 'package:socialv/screens/shop/screens/order_detail_screen.dart';
import 'package:socialv/store/shop_store.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:socialv/utils/cached_network_image.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<FilterModel> filterOptions = getOrderStatus();
  ShopStore ordersScreenVars = ShopStore();

  int mPage = 1;
  bool mIsLastPage = false;

  @override
  void initState() {
    ordersScreenVars.orderIndex = 0;
    getOrders();
    super.initState();
  }

  Future<void> getOrders({String? status}) async {
    appStore.setLoading(true);
    ordersScreenVars.isError = false;
    await getOrderList(status: status == null ? OrderStatus.any : status).then((value) {
      if (mPage == 1) ordersScreenVars.orderLists.clear();
      value.forEach((element) {
        element.shippingLines!.forEach((e) {
          log(e.total);
        });
      });
      mIsLastPage = value.length != 20;
      ordersScreenVars.orderLists.addAll(value);
      appStore.setLoading(false);
    }).catchError((e) {
      ordersScreenVars.isError = true;
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  Future<void> onRefresh() async {
    ordersScreenVars.isError = false;
    mPage = 1;
    getOrders(status: filterOptions[ordersScreenVars.orderIndex].value.validate().toLowerCase());
  }

  calculatePrice(double subTotal, int quantity) {
    return subTotal / quantity;
  }

  Future<void> onCancelOrder(int id) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CancelOrderBottomSheet(
          orderId: id,
          callback: (text) {
            showConfirmDialogCustom(
              context,
              onAccept: (c) {
                ifNotTester(() {
                  appStore.setLoading(true);
                  cancelOrder(orderId: id, note: text).then((value) {
                    toast(language.orderCancelledSuccessfully);
                    ordersScreenVars.orderStatus = OrderStatus.cancelled;
                    appStore.setLoading(false);
                    ordersScreenVars.isChange = true;
                  }).catchError((e) {
                    appStore.setLoading(false);
                    toast(e.toString(), print: true);
                  });
                });
              },
              dialogType: DialogType.CONFIRMATION,
              title: language.cancelOrderConfirmation,
              positiveText: language.yes,
              negativeText: language.no,
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    if (appStore.isLoading) appStore.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
      },
      color: context.primaryColor,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.iconColor),
            onPressed: () {
              finish(context);
            },
          ),
          titleSpacing: 0,
          title: Text(language.myOrders, style: boldTextStyle(size: 22)),
          elevation: 0,
          centerTitle: true,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              ///No data widget
              Observer(builder: (_) {
                return NoDataWidget(
                  imageWidget: NoDataLottieWidget(),
                  title: language.noDataFound,
                  onRetry: () {
                    onRefresh();
                  },
                  retryText: '   ${language.clickToRefresh}   ',
                ).center().visible(!appStore.isLoading && !ordersScreenVars.isError && ordersScreenVars.orderLists.isEmpty);
              }),

              ///Error widget
              Observer(builder: (_) {
                return NoDataWidget(
                  imageWidget: NoDataLottieWidget(),
                  title: language.somethingWentWrong,
                  onRetry: () {
                    onRefresh();
                  },
                  retryText: '   ${language.clickToRefresh}   ',
                ).center().visible(!appStore.isLoading && ordersScreenVars.isError);
              }),

              ///List Widget
              Column(
                children: [
                  HorizontalList(
                      itemCount: filterOptions.length,
                      itemBuilder: (context, index) {
                        return Observer(
                          builder: (_) => AppButton(
                            shapeBorder: RoundedRectangleBorder(borderRadius: radius(commonRadius)),
                            text: filterOptions[index].title.validate(),
                            textStyle: boldTextStyle(
                              color: ordersScreenVars.orderIndex == index
                                  ? Colors.white
                                  : appStore.isDarkMode
                                      ? bodyDark
                                      : bodyWhite,
                              size: 14,
                            ),
                            onTap: () {
                              getOrders(status: "${filterOptions[index].value!.toLowerCase()}");
                              ordersScreenVars.orderIndex = index;
                            },
                            elevation: 0,
                            color: ordersScreenVars.orderIndex == index ? context.primaryColor : context.scaffoldBackgroundColor,
                          ),
                        );
                      }).paddingSymmetric(horizontal: 8),
                  Observer(builder: (_) {
                    return AnimatedListView(
                      shrinkWrap: true,
                      slideConfiguration: SlideConfiguration(
                        delay: 80.milliseconds,
                        verticalOffset: 300,
                      ),
                      physics: AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                      itemCount: ordersScreenVars.orderLists.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            OrderDetailScreen(
                              orderDetails: ordersScreenVars.orderLists[index],
                              onCancel: () {
                                onCancelOrder(ordersScreenVars.orderLists[index].id!);
                              },
                            ).launch(context).then((value) {
                              if (value ?? false) {
                                mPage = 1;
                                getOrders();
                              }
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(color: context.cardColor, borderRadius: radius(defaultAppButtonRadius)),
                            padding: EdgeInsets.all(16),
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text('${language.orderNumber}: ', style: boldTextStyle(size: 14)),
                                        Text(ordersScreenVars.orderLists[index].id.validate().toString(), style: secondaryTextStyle()),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text('${language.date}: ', style: boldTextStyle(size: 14)),
                                        Text(formatDate(ordersScreenVars.orderLists[index].dateCreated.validate()), style: secondaryTextStyle()),
                                      ],
                                    ),
                                    10.height,
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: ordersScreenVars.orderLists[index].lineItems.validate().length,
                                      itemBuilder: (ctx, i) {
                                        LineItem orderItem = ordersScreenVars.orderLists[index].lineItems.validate()[i];
                                        return Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            cachedImage(
                                              orderItem.image!.src.validate(),
                                              height: 30,
                                              width: 30,
                                              fit: BoxFit.cover,
                                            ).cornerRadiusWithClipRRect(commonRadius),
                                            30.width,
                                            Expanded(child: Text('${orderItem.name.validate()}', style: secondaryTextStyle())),
                                            Text('${calculatePrice(orderItem.subtotal.toDouble(), orderItem.quantity!)}  *   ', style: secondaryTextStyle()),
                                            Text(' ${orderItem.quantity.validate()}   =  ${orderItem.subtotal}', style: secondaryTextStyle()),
                                          ],
                                        ).paddingSymmetric(vertical: 4);
                                      },
                                    ),
                                    Divider(height: 28),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text('${language.total}: ', style: boldTextStyle()),
                                        PriceWidget(price: ordersScreenVars.orderLists[index].total),
                                      ],
                                    ),
                                    16.height,
                                    if (ordersScreenVars.orderLists[index].status != "cancelled" && ordersScreenVars.orderLists[index].status != "completed")
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(color: context.primaryColor, borderRadius: radius(4)),
                                        child: Text(language.cancelOrder, style: primaryTextStyle(color: Colors.white)).center(),
                                      ).onTap(() {
                                        onCancelOrder(ordersScreenVars.orderLists[index].id!);
                                        log(language.cancelOrder);
                                      }, splashColor: Colors.transparent, highlightColor: Colors.transparent),
                                  ],
                                ),
                                Align(
                                  child: Container(
                                    decoration: BoxDecoration(color: context.primaryColor, borderRadius: radius(4)),
                                    child: Text(ordersScreenVars.orderLists[index].status.validate().capitalizeFirstLetter(), style: secondaryTextStyle(color: Colors.white)),
                                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  ),
                                  alignment: Alignment.topRight,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      onNextPage: () {
                        if (!mIsLastPage) {
                          mPage++;
                          getOrderList();
                        }
                      },
                    ).visible(!appStore.isLoading && !ordersScreenVars.isError && ordersScreenVars.orderLists.isNotEmpty).expand();
                  }),
                ],
              ),

              ///Loading widget
              Observer(
                builder: (_) {
                  if (appStore.isLoading) {
                    return Positioned(
                      bottom: mPage != 1 ? 10 : null,
                      child: LoadingWidget(isBlurBackground: mPage == 1 ? true : false),
                    );
                  } else {
                    return Offstage();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
