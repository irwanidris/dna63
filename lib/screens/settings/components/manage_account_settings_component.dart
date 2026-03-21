import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/blockReport/blocked_accounts.dart';
import 'package:socialv/screens/settings/screens/send_invitations_screen.dart';

import '../../../utils/app_constants.dart';

class ManageAccountSettingsComponent extends StatelessWidget {
  const ManageAccountSettingsComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingSection(
      title: Text(language.manageAccount.toUpperCase(), style: boldTextStyle(color: context.primaryColor)),
      headingDecoration: BoxDecoration(color: context.cardColor),
      items: [
        SettingItemWidget(
          title: language.invitations,
          titleTextStyle: primaryTextStyle(color: appStore.isDarkMode ? bodyDark : bodyWhite),
          leading: Image.asset(ic_message, height: 18, width: 18, color: appColorPrimary, fit: BoxFit.cover),
          trailing: Icon(Icons.arrow_forward_ios, color: appStore.isDarkMode ? bodyDark : bodyWhite, size: 16),
          onTap: () {
            SendInvitationsScreen().launch(context);
          },
        ),
        SettingItemWidget(
          title: language.blockedAccounts,
          titleTextStyle: primaryTextStyle(color: appStore.isDarkMode ? bodyDark : bodyWhite),
          leading: Image.asset(ic_close_square, height: 18, width: 18, color: appColorPrimary, fit: BoxFit.cover),
          trailing: Icon(Icons.arrow_forward_ios, color: appStore.isDarkMode ? bodyDark : bodyWhite, size: 16),
          onTap: () {
            BlockedAccounts().launch(context);
          },
        ),
        SettingItemWidget(
          title: language.deleteAccount,
          titleTextStyle: primaryTextStyle(color: Colors.redAccent),
          leading: Image.asset(ic_delete, height: 18, width: 18, color: Colors.redAccent, fit: BoxFit.cover),
          onTap: () {
            showConfirmDialogCustom(
              context,
              onAccept: (c) {
                ifNotTester(() async {
                  appStore.setLoading(true);
                  await deleteAccount().then((value) {
                    toast(value.message);
                    appStore.setVerificationStatus(VerificationStatus.pending);
                    logout(context, setId: false);
                  }).catchError((e) {
                    appStore.setLoading(false);
                    toast(e.toString());
                  });
                });
              },
              dialogType: DialogType.DELETE,
              title: language.deleteAccountConfirmation,
            );
          },
        ),
      ],
    );
  }
}
