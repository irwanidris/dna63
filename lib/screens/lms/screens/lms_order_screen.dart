import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/lms/lms_order_model.dart';
import 'package:socialv/screens/lms/screens/course_list_screen.dart';
import 'package:socialv/utils/app_constants.dart';

// ignore: must_be_immutable
class LmsOrderScreen extends StatelessWidget {
  LmsOrderModel orderDetail;
  OrderItem? orderItem;
  final bool isFromCheckOutScreen;

  LmsOrderScreen({required this.orderDetail, this.orderItem, this.isFromCheckOutScreen = false});

  Future<void> downloadCourseInvoice() async {
    try {
      if (orderDetail.orderItems.validate().isEmpty) {
        toast(language.orderDetailsNotFound);
        return;
      }

      String courseId = orderDetail.orderItems!.first.id.validate().toString();
      String userId = userStore.loginUserId.validate().toString();

      final File? invoiceFile = await InvoiceDownloader.downloadInvoice(
        type: InvoiceType.course,
        params: {
          'courseId': courseId,
          'userId': userId,
        },
      );

      if (invoiceFile != null) {
        print('Course Invoice downloaded to: ${invoiceFile.path}');
        toast(language.invoiceDownloadedSuccessfully);
      } else {
        toast(language.failedInvoiceDownload);
      }
    } catch (e) {
      print('Error downloading invoice: $e');
      toast("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language.course + " " + language.orderDetails, style: boldTextStyle(size: 20)),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () {
            if (isFromCheckOutScreen) {
              finish(context, false);
            } else {
              finish(context);
            }
          },
        ),
      ),
      body: AnimatedScrollView(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${language.course}' " " '${language.orderId}: ${orderDetail.orderNumber}', style: boldTextStyle()),
              OutlinedButton(
                onPressed: downloadCourseInvoice,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: context.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: Size(0, 34),
                  padding: EdgeInsets.symmetric(horizontal: 12),
                ),
                child: Text(
                  language.invoice,
                  style: boldTextStyle(color: context.primaryColor),
                ),
              ).visible(orderDetail.orderStatus == CourseStatus.completed),
            ],
          ),
          if (orderDetail.orderMethod.validate().isNotEmpty)
            Text(
              '${language.payVia}: ${orderDetail.orderMethod}',
              style: primaryTextStyle(),
            ).paddingTop(16),
          16.height,
          Container(
            width: context.width(),
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(color: context.cardColor, borderRadius: radius(commonRadius)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(language.course +" " + language.orderDetails, style: boldTextStyle(size: 18)),
                Divider(height: 20),
                12.height,
                Text('${language.dateCreated}: ${orderDetail.orderDate}', style: primaryTextStyle()),
                12.height,
                Text('${language.status}: ${orderDetail.orderStatus}', style: primaryTextStyle()),
                12.height,
                Text('${language.customer}: ${userStore.loginFullName}', style: primaryTextStyle()),
                12.height,
                Text('${language.email}: ${userStore.loginEmail}', style: primaryTextStyle()),
                12.height,
                Text('${language.orderKey}: ${orderDetail.orderKey}', style: primaryTextStyle()),
              ],
            ),
          ),
          16.height,
          Text(language.course + " " + language.orderItems, style: boldTextStyle(size: 18)),
          16.height,
          ListView.builder(
            itemCount: orderDetail.orderItems.validate().length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (ctx, index) {
              OrderItem item = orderDetail.orderItems.validate()[index];
              return Container(
                decoration: BoxDecoration(color: context.cardColor, borderRadius: radius(commonRadius)),
                padding: EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name.validate(), style: boldTextStyle()),
                    16.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${language.quantity}:', style: secondaryTextStyle()),
                        Spacer(),
                        Text('${item.quantity.validate()}', style: secondaryTextStyle()),
                        8.width,
                      ],
                    ),
                    8.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${language.subTotal}:', style: secondaryTextStyle()),
                        Spacer(),
                        Text('${item.salePrice.validate().isEmpty ? item.regularPrice : item.salePrice}', style: secondaryTextStyle()),
                        8.width,
                      ],
                    ).visible(item.regularPrice.validate().isNotEmpty),
                    10.height,
                    item.regularPrice.validate().isNotEmpty
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${language.total}:', style: primaryTextStyle(color: context.primaryColor)),
                        Spacer(),
                        Text('${item.salePrice.validate().isEmpty ? item.regularPrice : item.salePrice}', style: primaryTextStyle(color: context.primaryColor)),
                        8.width,
                      ],
                    )
                        : Text(language.free,style: primaryTextStyle(color: context.primaryColor)),
                  ],
                ),
              );
            },
          ),
          if (isFromCheckOutScreen)
            InkWell(
              onTap: () {
                CourseListScreen(myCourses: true).launch(context);
              },
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 16),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(color: context.primaryColor, borderRadius: radius(4)),
                child: Text(language.clickToVisitMyCourses, style: secondaryTextStyle(color: Colors.white)).center(),
              ),
            ),
        ],
      ).paddingAll(16),
    );
  }
}
