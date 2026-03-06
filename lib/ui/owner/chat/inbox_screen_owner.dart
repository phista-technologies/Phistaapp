import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../constant/collection_name.dart';
import '../../../constant/constant.dart';
import '../../../constant/show_toast_dialog.dart';
import '../../../controller/owner_controller/inbox_controller_owner.dart';
import '../../../model/user_model.dart';
import '../../../themes/app_them_data.dart';
import '../../../themes/common_ui.dart';
import '../../../themes/responsive.dart';
import '../../../utils/dark_theme_provider.dart';
import '../../../utils/fire_store_utils.dart';
import '../../../utils/network_image_widget.dart';
import '../../../widgets/firebase_pagination/src/firestore_pagination.dart';
import 'chat_screen_owner.dart';
import 'model/inbox_model_owner.dart';

/*class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<InboxController>(
      init: InboxController(),
      builder: (controller) {
        return Scaffold(
          appBar: UiInterface().customAppBar(
            context,
            themeChange,
            isBack: true,
            'Inbox'.tr,
          ),
          body: controller.isLoading.value
              ? Constant.loader()
              : FirestorePagination(
                  scrollDirection: Axis.vertical,
                  query:
                      FireStoreUtils.fireStore.collection(CollectionName.chat).doc(controller.senderUserModel.value.id).collection("inbox").orderBy("timestamp", descending: true),
                  isLive: true,
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  shrinkWrap: true,
                  reverse: true,
                  onEmpty: Constant.showEmptyView(message: "No conversion found".tr),
                  itemBuilder: (context, documentSnapshots, index) {
                    InboxModel inboxModel = InboxModel.fromJson(documentSnapshots[index].data() as Map<String, dynamic>);
                    return Container(
                        padding: const EdgeInsets.only(left: 14, right: 14, top: 06, bottom: 06),
                        child: InkWell(
                          onTap: () async {
                            ShowToastDialog.showLoader("Please wait".tr);
                            await FireStoreUtils.getUserProfile(
                                    controller.senderUserModel.value.id == inboxModel.senderId.toString() ? inboxModel.receiverId.toString() : inboxModel.senderId.toString())
                                .then((value) {
                              ShowToastDialog.closeLoader();
                              UserModel userModel = value!;
                              Get.to(const ChatScreen(), arguments: {"receiverModel": userModel});
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                            child: FutureBuilder<UserModel?>(
                                future: FireStoreUtils.getUserProfile(
                                    controller.senderUserModel.value.id == inboxModel.senderId.toString() ? inboxModel.receiverId.toString() : inboxModel.senderId.toString()),
                                builder: (context, snapshot) {
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.waiting:
                                      return Constant.loader();
                                    case ConnectionState.done:
                                      if (snapshot.hasError) {
                                        return Text(snapshot.error.toString());
                                      } else {
                                        UserModel? userModel = snapshot.data;
                                        return Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(60),
                                              child: NetworkImageWidget(
                                                imageUrl: userModel!.profilePic.toString(),
                                                height: Responsive.width(12, context),
                                                width: Responsive.width(12, context),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          userModel.fullName.toString(),
                                                          style: TextStyle(
                                                              color: themeChange.getThem() ? AppThemData.grey02 : AppThemData.grey09,
                                                              fontFamily: AppThemData.semiBold,
                                                              fontSize: 16),
                                                        ),
                                                      ),
                                                      Text(
                                                        Constant.timestampToDateChat(inboxModel.timestamp!),
                                                        style: TextStyle(
                                                            color: themeChange.getThem() ? AppThemData.grey02 : AppThemData.grey08, fontFamily: AppThemData.medium, fontSize: 12),
                                                      )
                                                    ],
                                                  ),
                                                  Text(
                                                    userModel.email.toString(),
                                                    style: TextStyle(
                                                        color: themeChange.getThem() ? AppThemData.grey02 : AppThemData.grey08, fontFamily: AppThemData.medium, fontSize: 14),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                    default:
                                      return Text('Error'.tr);
                                  }
                                }),
                          ),
                        ));
                  },
                ),
        );
      },
    );
  }
}*/
class InboxScreenOwner extends StatelessWidget {
  const InboxScreenOwner({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<InboxControllerOwner>(
      init: InboxControllerOwner(),
      builder: (controller) {
        // Prevent building until user data is loaded and id is available
        if (controller.isLoading.value || controller.senderUserModel.value.id == null || controller.senderUserModel.value.id!.isEmpty) {
          return Scaffold(
            appBar: UiInterface().customAppBar(
              context,
              themeChange,
              isBack: true,
              'Inbox'.tr,
            ),
            body: Constant.loader(),
          );
        }

        return Scaffold(
          appBar: UiInterface().customAppBar(
            context,
            themeChange,
            isBack: true,
            'Inbox'.tr,
          ),
          body: FirestorePagination(
            scrollDirection: Axis.vertical,
            query: FireStoreUtils.fireStore
                .collection(CollectionName.chat)
                .doc(controller.senderUserModel.value.id)
                .collection("inbox")
                .orderBy("timestamp", descending: true),
            isLive: true,
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            shrinkWrap: true,
            reverse: true,
            onEmpty: Constant.showEmptyView(message: "No conversion found".tr),
            itemBuilder: (context, documentSnapshots, index) {
              InboxModelOwner inboxModel = InboxModelOwner.fromJson(documentSnapshots[index].data() as Map<String, dynamic>);

              return Container(
                padding: const EdgeInsets.only(left: 14,right: 14,bottom: 6),
                child: InkWell(
                  onTap: () async {
                    ShowToastDialog.showLoader("Please wait".tr);
                    await FireStoreUtils.getUserProfile(
                      controller.senderUserModel.value.id == inboxModel.senderId.toString()
                          ? inboxModel.receiverId.toString() : inboxModel.senderId.toString(),
                    ).then((value) {
                      ShowToastDialog.closeLoader();
                      if (value != null) {
                        Get.to(const ChatScreenOwner(), arguments: {"receiverModel": value});
                      } else {
                        ShowToastDialog.showToast("User not found".tr);
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                    child: FutureBuilder<UserModel?>(
                      future: FireStoreUtils.getUserProfile(
                        controller.senderUserModel.value.id == inboxModel.senderId.toString()
                            ? inboxModel.receiverId.toString()
                            : inboxModel.senderId.toString(),
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Constant.loader();
                        }
                        if (snapshot.hasError) {
                          return Text(snapshot.error.toString());
                        }
                        if (!snapshot.hasData || snapshot.data == null) {
                          return SizedBox.shrink();
                        }
                        UserModel userModel = snapshot.data!;
                        return Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: NetworkImageWidget(
                                imageUrl: userModel.profilePic ?? '',
                                height: Responsive.width(12, context),
                                width: Responsive.width(12, context),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child:Text(
                                          controller.getFirstName(userModel.fullName),
                                          style: TextStyle(
                                            color: themeChange.getThem()
                                                ? AppThemData.grey02
                                                : AppThemData.grey09,
                                            fontFamily: AppThemData.semiBold,
                                            fontSize: 16,
                                          ),
                                        ) /* Text(
                                          userModel.fullName ?? '',
                                          style: TextStyle(
                                            color: themeChange.getThem() ? AppThemData.grey02 : AppThemData.grey09,
                                            fontFamily: AppThemData.semiBold,
                                            fontSize: 16,
                                          ),
                                        )*/,
                                      ),
                                      Text(
                                        inboxModel.timestamp != null
                                            ? Constant.timestampToDateChat(inboxModel.timestamp!)
                                            : '',
                                        style: TextStyle(
                                          color: themeChange.getThem() ? AppThemData.grey02 : AppThemData.grey08,
                                          fontFamily: AppThemData.medium,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    inboxModel.lastMessage ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 14, color: Colors.grey),
                                  ),
                                 /* Text(
                                    userModel.email ?? '',
                                    style: TextStyle(
                                      color: themeChange.getThem() ? AppThemData.grey02 : AppThemData.grey08,
                                      fontFamily: AppThemData.medium,
                                      fontSize: 14,
                                    ),
                                  ),*/
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

