import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:provider/provider.dart';

import '../../../constant/constant.dart';
import '../../../constant/show_toast_dialog.dart';
import '../../../controller/owner_controller/add_parking_details_controller_owner.dart';
import '../../../model/location_lat_lng.dart';
import '../../../themes/app_them_data.dart';
import '../../../themes/common_ui.dart';
import '../../../themes/custom_dialog_box.dart';
import '../../../themes/responsive.dart';
import '../../../themes/round_button_fill.dart';
import '../../../themes/text_field_widget.dart';
import '../../../utils/dark_theme_provider.dart';
import '../../../utils/fire_store_utils.dart';
import '../../../utils/network_image_widget.dart';
import '../../../utils/place_picker_osm.dart';
import 'availibility_screen_owner.dart';


class AddParkingDetailsScreenOwner extends StatelessWidget {
  const AddParkingDetailsScreenOwner({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<AddParkingDetailsControllerOwner>(
        init: AddParkingDetailsControllerOwner(),
        builder: (controller) {
          return Scaffold(
            appBar: UiInterface().customAppBar(
              context,
              themeChange,
              'add_parking'.tr,
              centerTile: kIsWeb?true:false
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : SingleChildScrollView(
                    child: kIsWeb?Center(
                      child: Container(
                        alignment: Alignment.center,
                        constraints: const BoxConstraints(maxWidth: 900),
                        margin: const EdgeInsets.all(20),
                        child: Card(
                          elevation: 7,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: _parkingDetailView(controller, context, themeChange),
                          ),
                      ),
                    )):Padding(
                      padding: const EdgeInsets.all(20),
                      child: _parkingDetailView(controller, context, themeChange),
                    ),
                  ),
            bottomNavigationBar:kIsWeb?null:_saveButton(themeChange, controller),
          );
        });
  }

  buildBottomSheet(BuildContext context, AddParkingDetailsControllerOwner controller) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return SizedBox(
              height: Responsive.height(22, context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text(
                      "please_select".tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: () => controller.pickFile(source: ImageSource.camera),
                                icon: const Icon(
                                  Icons.camera_alt,
                                  size: 32,
                                )),
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                "camera".tr,
                                style: const TextStyle(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: () => controller.pickFile(source: ImageSource.gallery),
                                icon: const Icon(
                                  Icons.photo_library_sharp,
                                  size: 32,
                                )),
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                "gallery".tr,
                                style: const TextStyle(),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            );
          });
        });
  }
  
  Widget _parkingDetailView(AddParkingDetailsControllerOwner controller, BuildContext context, DarkThemeProvider themeChange){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Parking For'.tr, style: const TextStyle(fontFamily: AppThemData.semiBold, fontSize: 16, color: AppThemData.grey07)),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
                child: Row(
                  children: [
                    SvgPicture.asset("assets/icon/ic_bike.svg", color: AppThemData.grey08),
                    const SizedBox(
                      width: 10,
                    ),
                    Text("2 Wheel".tr, style: const TextStyle(color: AppThemData.grey08, fontFamily: AppThemData.medium)),
                  ],
                )),
            Radio<String>(
              value: "2",
              groupValue: controller.parkingType.value,
              activeColor: AppThemData.primary07,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: const VisualDensity(
                horizontal: VisualDensity.minimumDensity,
                vertical: VisualDensity.minimumDensity,
              ),
              onChanged: controller.handleParkingChange,
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
                child: Row(
                  children: [
                    SvgPicture.asset("assets/icon/ic_car_fill.svg", color: AppThemData.grey08),
                    const SizedBox(
                      width: 10,
                    ),
                    Text("4 Wheel".tr, style: const TextStyle(color: AppThemData.grey08, fontFamily: AppThemData.medium)),
                  ],
                )),
            Radio<String>(
              value: "4",
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: const VisualDensity(
                horizontal: VisualDensity.minimumDensity,
                vertical: VisualDensity.minimumDensity,
              ),
              groupValue: controller.parkingType.value,
              activeColor: AppThemData.primary07,
              onChanged: controller.handleParkingChange,
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        controller.parkingImage.value.isNotEmpty
            ? InkWell(
          onTap: () {
            buildBottomSheet(
              context,
              controller,
            );
          },
          child: SizedBox(
            height: Responsive.height(20, context),
            width: Responsive.width(90, context),
            /*child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: Constant().hasValidUrl(controller.parkingImage.value) == false
                  ? Image.file(
                File(controller.parkingImage.value),
                height: Responsive.height(20, context),
                width: Responsive.width(80, context),
                fit: BoxFit.fill,
              )
                  : NetworkImageWidget(
                imageUrl: controller.parkingImage.value.toString(),
                fit: BoxFit.fill,
                height: Responsive.height(20, context),
                width: Responsive.width(80, context),
              ),
            )*/
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: controller.parkingImage.value.isEmpty
                    ? const SizedBox()
                    : Constant().hasValidUrl(controller.parkingImage.value)
                    ? NetworkImageWidget(
                  imageUrl: controller.parkingImage.value,
                  fit: BoxFit.fill,
                  height: Responsive.height(20, context),
                  width: Responsive.width(80, context),
                )
                    : kIsWeb
                    ? Image.network(
                  controller.parkingImage.value,
                  fit: BoxFit.fill,
                  height: Responsive.height(20, context),
                  width: Responsive.width(80, context),
                )
                    : Image.file(
                  File(controller.parkingImage.value),
                  fit: BoxFit.fill,
                  height: Responsive.height(20, context),
                  width: Responsive.width(80, context),
                ),
              ),
          ),
        )
            : InkWell(
          onTap: () {
            buildBottomSheet(
              context,
              controller,
            );
          },
          child: DottedBorder(
            borderType: BorderType.RRect,
            radius: const Radius.circular(12),
            dashPattern: const [6, 6, 6, 6],
            color: AppThemData.primary08,
            child: Container(
                color: AppThemData.primary01,
                height: Responsive.height(kIsWeb ?40:20, context),
                width: Responsive.width(90, context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.image, color: AppThemData.primary08, size: 32),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      "Upload image".tr,
                      style: TextStyle(fontFamily: AppThemData.medium, color: themeChange.getThem() ? AppThemData.primary08 : AppThemData.primary08),
                    )
                  ],
                )),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        TextFieldWidget(
          title: 'Parking Name'.tr,
          onPress: () {},
          controller: controller.nameController.value,
          hintText: 'Enter Parking Name'.tr,
          prefix: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SvgPicture.asset(
              "assets/icon/ic_parking_p.svg",
              colorFilter: const ColorFilter.mode(AppThemData.grey07, BlendMode.srcIn),
            ),
          ),
        ),
        InkWell(
          onTap: () async {
            if (Constant.selectedMapType == 'osm'|| kIsWeb) {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LocationPicker(
                      initialPosition: LatLng(-33.8567844, 151.213108)
                  ),
                ),
              );

              if (result != null) {
                controller.addressController.value.text = result["address"];
                controller.locationLatLng.value = LocationLatLng(
                  latitude: result["lat"],
                  longitude: result["lng"],
                );
              }
             /* Get.to(() => const LocationPicker(initialPosition: LatLng(-33.8567844, 151.213108),))?.then((value) {
                if (value != null) {
                  controller.addressController.value.text = value.displayName!.toString();
                  controller.locationLatLng.value = LocationLatLng(latitude: value.lat, longitude: value.lon);
                }
              });*/
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlacePicker(
                    apiKey: Constant.mapAPIKey,
                    onPlacePicked: (result) async {
                      Get.back();
                      controller.addressController.value.text = result.formattedAddress.toString();
                      controller.locationLatLng.value = LocationLatLng(
                        latitude: result.geometry!.location.lat,
                        longitude: result.geometry!.location.lng,
                      );
                    },
                    initialPosition: const LatLng(-33.8567844, 151.213108),
                    useCurrentLocation: true,
                    selectInitialPosition: true,
                    usePinPointingSearch: true,
                    usePlaceDetailSearch: true,
                    zoomGesturesEnabled: true,
                    zoomControlsEnabled: true,
                    resizeToAvoidBottomInset: false, // only works in page mode, less flickery, remove if wrong offsets
                  ),
                ),
              );
            }
          },
          child: TextFieldWidget(
            title: 'Address'.tr,
            onPress: () {},
            controller: controller.addressController.value,
            hintText: 'Enter Address'.tr,
            enable: false,
            prefix: const Icon(Icons.location_on_outlined),
          ),
        ),
        TextFieldWidget(
          title: 'Description'.tr,
          onPress: () {},
          controller: controller.detailsController.value,
          hintText: 'Enter Description'.tr,
          maxLine: 5,
        ),
        TextFieldWidget(
          title: 'Hourly Price'.tr,
          onPress: () {},
          textInputType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[0-9]')),
          ],
          controller: controller.priceController.value,
          hintText: 'Enter Price'.tr,
          prefix: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(Constant.currencyModel!.symbol.toString(), style: const TextStyle(fontSize: 20, color: AppThemData.grey08)),
          ),
        ),
        TextFieldWidget(
          title: 'Daily Price'.tr,
          onPress: () {},
          textInputType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[0-9]')),
          ],
          controller: controller.dailyPriceController.value,
          hintText: 'Enter Price'.tr,
          prefix: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(Constant.currencyModel!.symbol.toString(), style: const TextStyle(fontSize: 20, color: AppThemData.grey08)),
          ),
        ),
        TextFieldWidget(
          title: 'Monthly Price'.tr,
          onPress: () {},
          textInputType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[0-9]')),
          ],
          controller: controller.monthlyPriceController.value,
          hintText: 'Enter Price'.tr,
          prefix: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(Constant.currencyModel!.symbol.toString(), style: const TextStyle(fontSize: 20, color: AppThemData.grey08)),
          ),
        ),
        TextFieldWidget(
          title: 'Number Of Space'.tr,
          onPress: () {},
          controller: controller.parkingSpaceController.value,
          textInputType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[0-9]')),
          ],
          hintText: 'Enter The Number Of Space'.tr,
          prefix: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SvgPicture.asset(
              "assets/icon/ic_space.svg",
              colorFilter: const ColorFilter.mode(AppThemData.grey07, BlendMode.srcIn),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "open_close".tr,
              style: TextStyle(fontFamily: AppThemData.semiBold, fontSize: 16, color: themeChange.getThem() ? AppThemData.grey07 : AppThemData.grey07),
            ),
            SizedBox(
              width: 40,
              height: 20,
              child: Switch(
                value: controller.isOpen.value,
                onChanged: (value) {
                  controller.isOpen(value);
                },
                activeColor: AppThemData.primary06,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        ListTile(leading:SvgPicture.asset("assets/icon/ic_car_image.svg", height: 24, width: 24),
          title:Text(
            "Availability".tr,
            style: TextStyle(fontFamily: AppThemData.semiBold, fontSize: 16, color: themeChange.getThem() ? AppThemData.grey07 : AppThemData.grey07),
          ),
          horizontalTitleGap: 0,
          contentPadding: const EdgeInsets.symmetric(horizontal: 0),
          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
          onTap: () async {


            if(controller.parkingModel.value.id != null){
              var isBooked =  await FireStoreUtils.parkingBookedOrNot(controller.parkingModel.value.id);
              print("isBooked:--> $isBooked");
              if (!isBooked){
                Get.to(AvailibilityScreenOwner());
              }
              else{
                showDialog(context: context, builder: (BuildContext context){
                  return CustomDialogBoxOnlyOk(
                    title: "Alert".tr,
                    descriptions: "You cannot do it due to ongoing booking.".tr,
                    buttonText: "Okay",
                    bgColor: AppThemData.error07,
                    onButtonTap: (){
                      Get.back();
                    },
                    img: SvgPicture.asset('assets/icon/alert_ico.svg'),
                  );
                });
              }
            }else{
              Get.to(AvailibilityScreenOwner());
            }


          },
        ),
        const SizedBox(
          height: 20,
        ),
        Text(
          'Select Features'.tr,
          style: TextStyle(fontFamily: AppThemData.semiBold, fontSize: 16, color: themeChange.getThem() ? AppThemData.grey07 : AppThemData.grey07),
        ),
        ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: controller.parkingFacilitiesList
              .map((item) => CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            checkColor: themeChange.getThem() ? AppThemData.white : AppThemData.white,
            activeColor: AppThemData.primary07,
            value: controller.selectedParkingFacilitiesList.indexWhere((element) => element.id == item.id) == -1 ? false : true,
            dense: true,
            title: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: NetworkImageWidget(
                    imageUrl: item.image.toString(),
                    height: 20,
                    width: 20,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  item.name.toString(),
                  style: TextStyle(
                    fontFamily: AppThemData.medium,
                    fontSize: 16,
                    color: themeChange.getThem() ? AppThemData.grey01 : AppThemData.grey09,
                  ),
                ),
              ],
            ),
            onChanged: (value) {
              if (value == true) {
                controller.selectedParkingFacilitiesList.add(item);
              } else {
                controller.selectedParkingFacilitiesList
                    .removeAt(controller.selectedParkingFacilitiesList.indexWhere((element) => element.id == item.id));
              }
            },
          ))
              .toList(),
        ),
        const SizedBox(
          height: 20,
        ),
        !kIsWeb?SizedBox():_saveButton(themeChange, controller)
      ],
    );
  }

  Widget _saveButton(DarkThemeProvider themeChange, AddParkingDetailsControllerOwner controller){
    return Container(
      color: themeChange.getThem() ? AppThemData.grey10 : AppThemData.grey11,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: RoundedButtonFill(
          title: "Save".tr,
          color: AppThemData.primary06,
          onPress: () {
            print(controller.weekList);

            if (controller.nameController.value.text.isEmpty) {
              ShowToastDialog.showToast("Please enter parking name");
            } else if (controller.addressController.value.text.isEmpty) {
              ShowToastDialog.showToast("Please enter parking address");
            } else if (controller.detailsController.value.text.isEmpty) {
              ShowToastDialog.showToast("Please enter parking description");
            } else if (controller.priceController.value.text.isEmpty) {
              ShowToastDialog.showToast("Please enter parking pr hours price");
            }else if (controller.dailyPriceController.value.text.isEmpty) {
              ShowToastDialog.showToast("Please enter parking pr day price");
            }else if (controller.monthlyPriceController.value.text.isEmpty) {
              ShowToastDialog.showToast("Please enter parking pr month price");
            } else if (controller.parkingSpaceController.value.text.isEmpty) {
              ShowToastDialog.showToast("Please enter number of space");
            } else if(!controller.checkAvailability(controller.weekList)){
              ShowToastDialog.showToast("Please add at least one availability");
            } else {
              controller.saveDetails();
            }
          },
        ),
      ),
    );
  }

}
