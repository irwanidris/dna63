import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/main.dart';
import 'package:socialv/network/messages_repository.dart';
import 'package:socialv/screens/messages/components/message_member_component.dart';
import 'package:socialv/screens/messages/components/no_message_component.dart';
import 'package:socialv/utils/colors.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({Key? key}) : super(key: key);

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  TextEditingController searchController = TextEditingController();
  bool isError = false;

  @override
  void initState() {
    super.initState();

    searchController.addListener(() {
      if (searchController.text.isNotEmpty) {
        showClearTextIcon();
      } else {
        messageStore.hasShowClearTextIcon = false;
      }
    });
  }

  void showClearTextIcon() {
    if (!messageStore.hasShowClearTextIcon) {
      messageStore.hasShowClearTextIcon = true;
    } else {
      return;
    }
  }

  Future<void> search() async {
    appStore.setLoading(true);
    await getSuggestions(searchText: searchController.text.validate()).then((value) {
      if (value.isEmpty) toast(language.noUserFound);
      messageStore.users.addAll(value);
      isError = false;
      appStore.setLoading(false);
    }).catchError((e) {
      isError = true;
      appStore.setLoading(false);
    });
  }

  @override
  void dispose() {
    messageStore.hasShowClearTextIcon = false;
    messageStore.users.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language.startANewConversation, style: boldTextStyle(size: 20)),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () {
            finish(context);
          },
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Observer(builder: (context) {
                  return AppTextField(
                    controller: searchController,
                    textFieldType: TextFieldType.USERNAME,
                    onChanged: (p0) {
                      if (searchController.text.isNotEmpty) {
                        messageStore.hasShowClearTextIcon = true;
                        search();
                      } else {
                        messageStore.hasShowClearTextIcon = false;
                      }
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: context.cardColor,
                      border: InputBorder.none,
                      hintText: language.startTypingToSearch,
                      hintStyle: primaryTextStyle(),
                      prefixIcon: Text('${language.to}:', style: boldTextStyle()).paddingSymmetric(horizontal: 16, vertical: 14),
                      suffixIcon: messageStore.hasShowClearTextIcon
                          ? IconButton(
                              icon: Icon(Icons.cancel, color: appStore.isDarkMode ? bodyDark : bodyWhite, size: 18),
                              onPressed: () {
                                hideKeyboard(context);
                                messageStore.hasShowClearTextIcon = false;
                                searchController.clear();
                                messageStore.users.clear();
                              },
                            )
                          : null,
                    ),
                  );
                }),
                Observer(builder: (context) {
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    itemCount: messageStore.users.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (ctx, index) {
                      return MessageMemberComponent(user: messageStore.users[index]);
                    },
                  ).visible(messageStore.users.isNotEmpty);
                }),
                Observer(builder: (context) {
                  return NoMessageComponent().center().visible(messageStore.users.isEmpty);
                })
              ],
            ),
          ),
          Observer(builder: (_) => LoadingWidget().visible(appStore.isLoading).center()),
        ],
      ),
    );
  }
}
