import 'package:heraj/config/app_color.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/core/service/localization_service/localization_service.dart';
import 'package:heraj/helper/responsive.dart';
import 'package:heraj/ui/shared_widgets/scaffold_back_ground.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

class LanguagesScreen extends StatelessWidget {
  const LanguagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldBackGround(
      title: "Language".tr,
      child: Column(
        children: [
          Gap(20.h),
          ...localeService.getAllLanguages.map((e) => Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: localeService.getLocale() == e
                        ? AppColor.primary
                        : AppColor.grey3,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  selectedColor: AppColor.primary.withOpacity(.8),
                  selectedTileColor: AppColor.primary.withOpacity(.2),
                  tileColor: AppColor.white,
                  selected: localeService.getLocale() == e,
                  leading: e.flag.endsWith(".png")
                      ? Image.asset(
                          e.flag,
                          height: 30,
                          width: 40,
                        )
                      : SvgPicture.asset(
                          e.flag,
                          height: 30,
                          width: 40,
                        ),
                  title: Text(
                    e.name.tr,
                    style: localeService.getLocale() == e
                        ? AppFont.font16W600Primary
                        : AppFont.font16W600Black,
                  ),
                  onTap: () {
                    localeService.changeLocale(e);
                  },
                ),
              )),
        ],
      ),
    );
  }
}
