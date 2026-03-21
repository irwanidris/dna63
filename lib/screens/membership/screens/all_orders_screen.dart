import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/network/pmp_repositry.dart';
import 'package:socialv/screens/membership/screens/pmp_order_detail_screen.dart';
import 'package:socialv/store/profile_menu_store.dart';
import '../../../utils/app_constants.dart';

class AllOrdersScreen extends StatefulWidget {
  const AllOrdersScreen({Key? key}) : super(key: key);

  @override
  State<AllOrdersScreen> createState() => _AllOrdersScreenState();
}

class _AllOrdersScreenState extends State<AllOrdersScreen> {
  ProfileMenuStore allOrdersScreenVars = ProfileMenuStore();
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    getOrdersList();
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (!allOrdersScreenVars.mIsLastPage && allOrdersScreenVars.allOrderList.isNotEmpty) {
          allOrdersScreenVars.mPage++;
          getOrdersList();
        }
      }
    });
  }

  Future<void> getOrdersList() async {
    appStore.setLoading(true);

    await pmpOrders(page: allOrdersScreenVars.mPage).then((value) {
      if (allOrdersScreenVars.mPage == 1) allOrdersScreenVars.allOrderList.clear();
      allOrdersScreenVars.mIsLastPage = value.length != 20;
      allOrdersScreenVars.allOrderList.addAll(value);

      appStore.setLoading(false);
    }).catchError((e) {
      allOrdersScreenVars.isError = true;
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          "${language.pastInvoices}",
          style: boldTextStyle(size: 22),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            /// error  widget
            Observer(builder: (context) {
              return allOrdersScreenVars.isError && !appStore.isLoading
                  ? SizedBox(
                      height: context.height() * 0.88,
                      child: NoDataWidget(
                        imageWidget: NoDataLottieWidget(),
                        title: language.somethingWentWrong,
                      ).center(),
                    )
                  : Offstage();
            }),

            /// empty widget
            Observer(builder: (context) {
              return allOrdersScreenVars.allOrderList.isEmpty && !allOrdersScreenVars.isError && !appStore.isLoading
                  ? SizedBox(
                      height: context.height() * 0.88,
                      child: NoDataWidget(
                        imageWidget: NoDataLottieWidget(),
                        title: language.noDataFound,
                      ).center(),
                    )
                  : Offstage();
            }),

            /// list widget
            Observer(builder: (context) {
              return allOrdersScreenVars.allOrderList.isNotEmpty && !allOrdersScreenVars.isError
                  ? ListView.builder(
                      controller: _scrollController,
                      shrinkWrap: true,
                      itemCount: allOrdersScreenVars.allOrderList.length,
                      itemBuilder: (context, index) {
                        return Card(
                            child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              "${index + 1}",
                              style: secondaryTextStyle(size: 15, color: Colors.white),
                            ),
                          ),
                          title: Text("${allOrdersScreenVars.allOrderList[index].membershipName.validate()}"),
                          subtitle: Row(
                            children: [
                              Text("${DateFormat(DATE_FORMAT_5).format(DateTime.parse(allOrdersScreenVars.allOrderList[index].timestamp.validate()))}"),
                              SizedBox(
                                width: 20,
                              ),
                              Text("${DateFormat(TIME_FORMAT_1).format(DateTime.parse(allOrdersScreenVars.allOrderList[index].timestamp.validate()))}")
                            ],
                          ),
                          trailing: Text("${appStore.wooCurrency} ${allOrdersScreenVars.allOrderList[index].total}").visible(!allOrdersScreenVars.allOrderList[index].membershipName.validate().toLowerCase().contains("free")),
                        )).paddingSymmetric(horizontal: 16, vertical: 6).onTap(() {
                          PmpOrderDetailScreen(
                            orderDetail: allOrdersScreenVars.allOrderList[index],
                            isFromCheckOutScreen: true,
                          ).launch(context);
                        });
                      })
                  : Offstage();
            }),

            /// Initial Loading  widget
            Observer(builder: (context) {
              return appStore.isLoading && allOrdersScreenVars.allOrderList.isEmpty
                  ? SizedBox(
                      height: context.height() * 0.88,
                      child: LoadingWidget().center(),
                    )
                  : Offstage();
            }),

            ///More data loading widget
            Observer(builder: (_) {
              return Positioned(
                left: 0,
                right: 0,
                bottom: 10,
                child: ThreeBounceLoadingWidget().visible(allOrdersScreenVars.mPage > 1 && !allOrdersScreenVars.mIsLastPage),
              );
            }),
          ],
        ),
      ),
    );
  }
}
