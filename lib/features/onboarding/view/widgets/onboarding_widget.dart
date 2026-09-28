import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../config/app_assets.dart';
import '../../data/onboard_list.dart';
import '../../data/onboarding_model.dart';

Widget buildOnBoardingItem(
        OnboardModel model, double height, PageController controller) =>
    Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            AppAssets.onboardBack,
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height * .4, child: Image.asset(model.image!)),
                SmoothPageIndicator(
                    controller: controller, count: onboardList.length),
                const Gap(10),
                Text(model.title!,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 30)),
                const Gap(10),
                Text(model.subTitle!,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 14)),
              ],
            ),
          ),
        ),
      ],
    );
