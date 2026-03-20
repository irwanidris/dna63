import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/store/app_store.dart';

import '../../../utils/app_constants.dart';

class AdComponent extends StatefulWidget {
  const AdComponent({Key? key}) : super(key: key);

  @override
  State<AdComponent> createState() => _AdComponentState();
}

class _AdComponentState extends State<AdComponent> {
  late BannerAd myBanner;
  AppStore adComponentVars = AppStore();

  @override
  void initState() {
    loadAd();
    super.initState();
  }

  void loadAd() async {
    myBanner = BannerAd(
      adUnitId: kReleaseMode
          ? isIOS
              ? mAdMobBannerIdIOS
              : mAdMobBannerId
          : mTestAdMobBannerId,
      size: AdSize.mediumRectangle,
      request: AdRequest(),
      listener: BannerAdListener(onAdLoaded: (ad) {
        adComponentVars.isAdLoaded = true;
      }, onAdFailedToLoad: (ad, error) {
        //
      }),
    );

    await myBanner.load();
  }

  @override
  void dispose() {
    myBanner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return adComponentVars.isAdLoaded
          ? Container(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(borderRadius: radius(commonRadius), color: context.cardColor),
              height: AdSize.mediumRectangle.height.toDouble(),
              child: AdWidget(ad: myBanner),
            )
          : Offstage();
    });
  }
}
