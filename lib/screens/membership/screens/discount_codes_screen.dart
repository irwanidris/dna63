import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/base_scaffold_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/pmp_models/discount_code_model.dart';
import 'package:socialv/models/pmp_models/membership_model.dart';
import 'package:socialv/network/pmp_repositry.dart';
import 'package:socialv/screens/membership/components/plan_subtitle_component.dart';
import 'package:socialv/store/profile_menu_store.dart';

import '../../../utils/app_constants.dart';

class DiscountCodesScreen extends StatefulWidget {
  final String planID;
  final Function(String, MembershipModel) onApply;

  const DiscountCodesScreen({required this.planID, required this.onApply});

  @override
  State<DiscountCodesScreen> createState() => _DiscountCodesScreenState();
}

class _DiscountCodesScreenState extends State<DiscountCodesScreen> {
  ProfileMenuStore discountCodesScreenVars = ProfileMenuStore();

  @override
  void initState() {
    super.initState();
    getCodeList();
  }

  Future<void> getCodeList() async {
    discountCodesScreenVars.isError = false;
    appStore.setLoading(true);
    discountCodesScreenVars.codeList.clear();
    await getDiscountCodeList(planId: widget.planID).then((value) {
      log("$value");
      discountCodesScreenVars.codeList.addAll(value.validate());
      appStore.setLoading(false);
    }).catchError((e) {
      discountCodesScreenVars.isError = true;
      log(e.toString());
      appStore.setLoading(false);
    });
  }

  Color getColor(DiscountCode code) {
    if (discountCodesScreenVars.selectedCode == code) {
      return context.primaryColor;
    } else if (appStore.isDarkMode) {
      return bodyDark;
    } else {
      return bodyWhite;
    }
  }

  @override
  void dispose() {
    if (appStore.isLoading) appStore.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return AppScaffold(
        appBarTitle: language.discountCodes,
        child: Stack(
          children: [
            ///No data widget
            Observer(builder: (_) {
              return NoDataWidget(
                imageWidget: NoDataLottieWidget(),
                title: language.noDataFound,
              ).center().visible(!appStore.isLoading && !discountCodesScreenVars.isError && discountCodesScreenVars.codeList.isEmpty);
            }),

            ///Error Widget
            Observer(builder: (_) {
              return NoDataWidget(
                imageWidget: NoDataLottieWidget(),
                title: language.somethingWentWrong,
                onRetry: () {
                  getCodeList();
                },
                retryText: '   ${language.clickToRefresh}   ',
              ).center().visible(!appStore.isLoading && discountCodesScreenVars.isError);
            }),

            ///Discount list
            Observer(builder: (_) {
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: discountCodesScreenVars.codeList.length,
                itemBuilder: (ctx, index) {
                  DiscountCode code = discountCodesScreenVars.codeList[index];
                  return Observer(builder: (context) {
                    return GestureDetector(
                      onTap: () {
                        if (discountCodesScreenVars.selectedCode != code)
                          discountCodesScreenVars.selectedCode = code;
                        else
                          discountCodesScreenVars.selectedCode = null;
                      },
                      child: Stack(
                        fit: StackFit.passthrough,
                        children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            margin: EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: getColor(code), width: 1),
                              color: discountCodesScreenVars.selectedCode == code ? getColor(code).withAlpha(30) : context.cardColor,
                              borderRadius: radius(commonRadius),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(code.code.validate(), style: boldTextStyle()),
                                8.height,
                                PlanSubtitleComponent(plan: code.plans.validate().first),
                                8.height,
                                Text('${language.validTill} ${code.expires}', style: secondaryTextStyle()),
                              ],
                            ),
                          ),
                          Positioned(
                            child: IconButton(
                              onPressed: () {
                                if (discountCodesScreenVars.selectedCode != code)
                                  discountCodesScreenVars.selectedCode = code;
                                else
                                  discountCodesScreenVars.selectedCode = null;
                              },
                              icon: Icon(
                                discountCodesScreenVars.selectedCode == code ? Icons.radio_button_checked : Icons.circle_outlined,
                                color: discountCodesScreenVars.selectedCode == code ? context.primaryColor : context.iconColor,
                              ),
                            ),
                            right: 0,
                            top: 8,
                          )
                        ],
                      ),
                    );
                  });
                },
              ).visible(!appStore.isLoading && !discountCodesScreenVars.isError && discountCodesScreenVars.codeList.isNotEmpty);
            })
          ],
        ),
        bottomNavigationBar: discountCodesScreenVars.selectedCode != null
            ? AppButton(
                width: context.width() - 32,
                text: language.select,
                elevation: 0,
                textStyle: boldTextStyle(color: Colors.white),
                color: context.primaryColor,
                onTap: () {
                  widget.onApply(discountCodesScreenVars.selectedCode!.code.validate(), discountCodesScreenVars.selectedCode!.plans.validate().first);
                },
              ).paddingAll(16)
            : Offstage(),
      );
    });
  }
}
