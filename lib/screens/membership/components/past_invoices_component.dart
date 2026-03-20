import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';
import 'package:socialv/network/pmp_repositry.dart';
import 'package:socialv/screens/membership/screens/all_orders_screen.dart';
import 'package:socialv/screens/membership/screens/pmp_order_detail_screen.dart';
import 'package:socialv/store/profile_menu_store.dart';

import '../../../utils/app_constants.dart';

class PastInvoicesComponent extends StatefulWidget {
  const PastInvoicesComponent({Key? key}) : super(key: key);

  @override
  State<PastInvoicesComponent> createState() => _PastInvoicesComponentState();
}

class _PastInvoicesComponentState extends State<PastInvoicesComponent> {
  ProfileMenuStore pastInvoicesComponentVars = ProfileMenuStore();

  @override
  void initState() {
    getOrders();
    super.initState();
  }

  Future<void> getOrders({String? status}) async {
    await pmpOrders().then((value) {
      pastInvoicesComponentVars.pastOrderList.addAll(value);
    }).catchError((e) {
      log(e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return pastInvoicesComponentVars.pastOrderList.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: context.cardColor,
                  margin: EdgeInsets.only(top: 16, bottom: 8),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(language.history, style: boldTextStyle(size: 18)),
                      if (pastInvoicesComponentVars.pastOrderList.length > 5)
                        TextButton(
                          onPressed: () {
                            AllOrdersScreen().launch(context);
                          },
                          child: Text(
                            language.viewAll,
                            style: boldTextStyle(color: context.primaryColor, size: 14),
                          ),
                        )
                    ],
                  ),
                ),
                ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: pastInvoicesComponentVars.pastOrderList.length > 5 ? 5 : pastInvoicesComponentVars.pastOrderList.length,
                    itemBuilder: (context, index) {
                      return Card(
                          child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            "${index + 1}",
                            style: secondaryTextStyle(size: 15, color: Colors.white),
                          ),
                        ),
                        title: Text("${pastInvoicesComponentVars.pastOrderList[index].membershipName.validate()}"),
                        subtitle: Row(
                          children: [
                            Text("${DateFormat(DATE_FORMAT_5).format(DateTime.parse(pastInvoicesComponentVars.pastOrderList[index].timestamp.validate()))}"),
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                                "${DateFormat(TIME_FORMAT_1).format(DateTime.parse(pastInvoicesComponentVars.pastOrderList[index].timestamp.validate())).replaceAll('AM', 'am').replaceAll('PM', 'pm')}")
                          ],
                        ),
                        trailing: Text("${appStore.wooCurrency} ${pastInvoicesComponentVars.pastOrderList[index].total}")
                            .visible(!pastInvoicesComponentVars.pastOrderList[index].membershipName.validate().toLowerCase().contains("free")),
                      )).paddingSymmetric(vertical: 6).onTap(() {
                        PmpOrderDetailScreen(
                          orderDetail: pastInvoicesComponentVars.pastOrderList[index],
                          isFromCheckOutScreen: true,
                        ).launch(context);
                      });
                    })
              ],
            )
          : Offstage();
    });
  }
}
