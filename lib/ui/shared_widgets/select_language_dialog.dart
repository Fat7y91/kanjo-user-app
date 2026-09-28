import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../config/app_color.dart';
import '../../config/app_assets.dart';
import '../../config/app_font.dart';
import '../../core/enum/language.dart';
import '../../core/service/localization_service/localization_service.dart';
import '../../helper/responsive.dart';
import 'image_or_svg.dart';

final selectLanguageProvider = StateProvider.autoDispose<Language>((ref) {
  return localeService.getLocale();
});

class SelectLanguageDialog extends ConsumerWidget {
  const SelectLanguageDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context, ref) {
    final currentLang = ref.read(selectLanguageProvider);
    responsiveInit(context);
    return Container(
      height: 200.0.h,
      decoration: BoxDecoration(
        color: AppColor.nearlyWhite,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: CupertinoPicker(
          scrollController: FixedExtentScrollController(
            initialItem: currentLang.index,
          ),
          itemExtent: 60,
          onSelectedItemChanged: (value) {
            localeService.changeLocale(Language.values
                .firstWhere((element) => element.index == value));
          },
          children: Language.values
              .map((e) => Container(
                    alignment: Alignment.center,
                    height: 50,
                    child: Directionality(
                      // layoutDirection: TextDirection.ltr,
                      textDirection: TextDirection.rtl,
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            e.flag,
                            height: 40,
                            width: 50,
                          ),
                          Gap(16.w),
                          Text(
                            e.name.tr,
                            style: AppFont.font15W700Black,
                          ),
                        ],
                      ),
                    ),
                  ))
              .toList()),
    );
  }
}
