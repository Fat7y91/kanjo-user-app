import 'package:flutter/cupertino.dart';
import 'package:heraj/helper/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../config/app_font.dart';
import '../../core/service/auth_service.dart';
import '../../core/service/local_data_manager.dart';
import '../../features/root/controller/root_role_controllers.dart';
import 'container_button.dart';
import 'custom_filled_button.dart';
import 'custom_image_circle.dart';

class CustomAppBar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.hideBackButton = false,
    this.customWidget,
    this.actionWidget,
    this.enableDrag = false,
    this.scrollController,
    this.customBackFunction,
    this.color,
    this.isCenterTitle = true,
    this.customTitleWidget,
  });

  final String title;
  final Widget? customTitleWidget;
  final ScrollController? scrollController;
  final bool hideBackButton;
  final bool enableDrag;
  final bool isCenterTitle;
  final Widget? actionWidget;
  final Color? color;
  final void Function()? customBackFunction;
  final List<Widget>? customWidget;

  @override
  ConsumerState<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(75.h);
}

@override
class _CustomAppBarState extends ConsumerState<CustomAppBar> {
  final transparentAppBar = StateProvider.autoDispose<bool>((ref) {
    return true;
  });

  @override
  void initState() {
    if (widget.enableDrag && widget.scrollController != null) {
      widget.scrollController!.addListener(() {
        if (widget.scrollController!.position.pixels < 0) {
          ref.read(transparentAppBar.notifier).state = false;
        } else if (widget.scrollController!.position.pixels > 20) {
          ref.read(transparentAppBar.notifier).state = false;
        } else {
          ref.read(transparentAppBar.notifier).state = true;
        }
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    responsiveInit(context);
    return SafeArea(
      top: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: GestureDetector(
            onTap: widget.scrollController == null
                ? null
                : () {
                    if (widget.scrollController?.hasClients == true) {
                      widget.scrollController?.animateTo(
                        0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                      ref.read(hideNavBarProvider.notifier).state = false;
                    }
                  },
            child: AppBar(
              backgroundColor: widget.color,
              centerTitle: widget.isCenterTitle,
              title: widget.customTitleWidget ??
                  Text(
                    widget.title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
              leading: widget.hideBackButton || widget.isCenterTitle == false
                  ? null
                  : ContainerButton(
                      icon: Icons.arrow_back_outlined,
                      color:Get.isDarkMode?AppColor.unselectedNavBar:AppColor.grey1,
                      onTap: () => Get.back(),
                    ),
              actions: widget.actionWidget!=null?[widget.actionWidget!]:null,
            )),
      ),
    );
  }
}

class CustomAppBar2 extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  const CustomAppBar2(
      {super.key,
      required this.title,
      this.hideBackButton = false,
      this.backgroundColor,
      this.showHomeBackButton = false,
      this.customWidget,
      this.actionWidget,
      this.enableDrag = false,
      this.scrollController,
      this.customBackFunction});

  final String title;
  final Color? backgroundColor;
  final ScrollController? scrollController;
  final bool hideBackButton;
  final bool showHomeBackButton;
  final bool enableDrag;
  final Widget? actionWidget;
  final void Function()? customBackFunction;
  final List<Widget>? customWidget;

  @override
  ConsumerState<CustomAppBar2> createState() => _CustomAppBarState2();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

@override
class _CustomAppBarState2 extends ConsumerState<CustomAppBar2> {
  final transparentAppBar = StateProvider.autoDispose<bool>((ref) {
    return true;
  });

  @override
  void initState() {
    if (widget.enableDrag &&
        widget.scrollController != null &&
        widget.backgroundColor != null) {
      widget.scrollController!.addListener(() {
        if (widget.scrollController!.position.pixels < 0) {
          ref.read(transparentAppBar.notifier).state = false;
        } else if (widget.scrollController!.position.pixels > 20) {
          ref.read(transparentAppBar.notifier).state = false;
        } else {
          ref.read(transparentAppBar.notifier).state = true;
        }
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    responsiveInit(context);
    return GestureDetector(
      onTap: widget.scrollController == null
          ? null
          : () {
              if (widget.scrollController?.hasClients == true) {
                widget.scrollController?.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
                ref.read(hideNavBarProvider.notifier).state = false;
              }
            },
      child: AppBar(
        centerTitle: false,
        backgroundColor:
            ref.watch(transparentAppBar) ? widget.backgroundColor : null,
        title: Text(
          widget.title,
          style: AppFont.font20W600Black,
        ),
        actions: [
          if (widget.actionWidget != null) ...[
            widget.actionWidget!,
            Gap(16.w),
          ],
        ],
      ),
    );
  }
}




class GeneralAppBar extends ConsumerWidget {
  final bool showSwitch;
  final bool hideSearchBar;

  const GeneralAppBar({
    super.key,
    this.showSwitch = false,
    this.hideSearchBar = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      backgroundColor: AppColor.primary,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16))),
      bottom: hideSearchBar
          ? PreferredSize(
          preferredSize: Size(double.infinity, 10), child: SizedBox())
          : PreferredSize(
        preferredSize: Size(double.infinity, 70),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              const Gap(12),
              InkWell(
                onTap: (){
                  // Get.to(()=> AllCarsScreen());
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColor.white),
                  ),
                  child: Row(
                    spacing: 16,
                    children: [
                      Icon(
                        CupertinoIcons.search,
                        color: AppColor.white,
                      ),
                      Text("search".tr,
                          style: AppFont.font16W600NearlyWhite),
                    ],
                  ),
                ),
              ),
              Gap(12.h),
            ],
          ),
        ),
      ),
      title: Row(
        spacing: 6.w,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomImageCircle(image: ref.watch(userProvider)?.image??""),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 3.h,
            children: [
              Row(
                spacing: 4,
                children: [
                  Text('Welcome back'.tr, style: AppFont.font18W700NearlyWhite),
                  Text(dataManager.getUser()?.name ?? "",
                      style: AppFont.font18W700NearlyWhite),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: AppColor.white,
                    size: 14,
                  ),
                  Text(
                    'احمد الصاوي مدينة نصر',
                    style: AppFont.font12W600White.copyWith(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        if (showSwitch)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8.0),
            child: CustomFilledButton(
              onPressed: () {
                if (ref.watch(rootViewProvider) == 0) {
                  ref.read(rootViewProvider.notifier).state = 1;
                } else {
                  ref.read(rootViewProvider.notifier).state = 0;
                }
              },
              width: 110,
              height: 45,
              padding: 8,
              textSize: 14,
              color: AppColor.white,
              fontColor: AppColor.primary,
              isExpanded: true,
              text: ref.watch(rootViewProvider) == 0 ? "Pharmacy".tr : "Clinic".tr,
              widget: Icon(
                Icons.switch_left_sharp,
                color: AppColor.primary,
              ),
            ),
          )
      ],
    );
  }
}

class GeneralAppBar2 extends ConsumerWidget {
  final String title;
  final bool showBack;

  const GeneralAppBar2({
    super.key,
    required this.title,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
          color: AppColor.primary,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          )),
      child: Padding(
        padding: EdgeInsets.all(12).copyWith(top: MediaQuery.of(context).padding.top + 10,bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (showBack)
              SizedBox(
                width: 40,
                child: IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  color: AppColor.white,
                  icon: Icon(
                    Icons.arrow_back,
                    color: AppColor.white,
                  ),
                ),
              ),
            if (!showBack) const Gap(40),
            Text(title, style: AppFont.font20W700NearlyWhite),
            const Gap(40),
          ],
        ),
      ),
    );
  }
}
