import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';
import 'package:socialv/screens/groups/components/invite_user_component.dart';

import '../../../utils/app_constants.dart';

class CreateGroupStepFour extends StatelessWidget {
  final VoidCallback? onFinish;

  const CreateGroupStepFour({this.onFinish});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: radiusOnly(topRight: defaultRadius, topLeft: defaultRadius),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Observer(
                  builder: (_) {
                    bool canFinish = groupStore.invitedMembersCount > 1;

                    return Container(
                      width: context.width(),
                      color: canFinish ? Colors.green.withValues(alpha: 0.1) : Colors.amber.withValues(alpha: 0.2),
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Text(
                        canFinish
                            ? '${groupStore.invitedMembersCount.toString()} ${language.membersInvited}!'
                            : '${language.youNeedToInviteMore} (${groupStore.invitedMembersCount.toString()} ${language.invited})',
                        style: secondaryTextStyle(
                          color: canFinish ? Colors.green : Colors.amber.shade800,
                        ),
                      ),
                    );
                  }
              ),

              InviteUserComponent().expand(),
            ],
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: context.width(),
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
              color: context.cardColor,
              child: Observer(
                  builder: (_) {
                    bool canFinish = groupStore.invitedMembersCount > 1;

                    return appButton(
                      text: language.finish.capitalizeFirstLetter(),
                      onTap: canFinish
                          ? () {
                        onFinish?.call();
                      }
                          : () {
                        toast(language.inviteMoreThan1);
                      },
                      context: context,
                      color: canFinish ? context.primaryColor : gray.withValues(alpha: 0.5),
                    );
                  }
              ),
            ),
          ),
        ],
      ),
    );
  }
}