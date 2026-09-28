import 'package:heraj/config/app_font.dart';
import 'package:flutter/material.dart';
import 'custom_app_bar.dart';

class ScaffoldBackGround extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? bottomNavigationBar;
  final Future<void> Function()? onRefresh;
  final ScrollController? controller;
  final bool isRoot;
  final void Function()? onBackTap;
  final void Function()? onRingTap;

  const ScaffoldBackGround({
    super.key,
    required this.title,
    required this.child,
    this.bottomNavigationBar,
    this.isRoot = false,
    this.onBackTap,
    this.onRingTap, this.onRefresh, this.controller
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 60),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: RefreshIndicator(
                onRefresh: onRefresh??()async{},
                child: SingleChildScrollView(
                  controller: controller,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      child,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(top: 0,right: 0,left: 0,child: GeneralAppBar2(title: title,showBack: !isRoot,),),
          if(bottomNavigationBar != null)
          Positioned(bottom: 0,left: 0,right: 0,child: bottomNavigationBar!,),
        ],
      ),
    );
  }
}

class ScaffoldSliversBackGround extends StatelessWidget {
  final List<Widget> slivers;
  final Widget? divider;
  final Widget? appBar;
  final String title;
  final Future<void> Function()? onRefresh;
  final EdgeInsetsGeometry? padding;
  final bool enablePadding;
  final bool hideAppBar;
  final bool showAppBarSwitcher;
  final bool hideSearchBar;

  const ScaffoldSliversBackGround({
    super.key,
    required this.slivers,
    this.divider,
    this.appBar,
    this.title = "Title",
    this.padding,
    this.onRefresh,
    this.hideAppBar = false,
    this.enablePadding = false,
    this.showAppBarSwitcher = false,
    this.hideSearchBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              bottom: -50,
              left: -50,
              height: 300,
              width: 300,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.primary2,
                      spreadRadius: 20,
                      blurRadius: 30
                    )
                  ]
                ),
              )),
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: enablePadding==true ? padding! : EdgeInsetsGeometry.zero,
              child: RefreshIndicator(
                onRefresh: onRefresh??()async{},
                child: CustomScrollView(
                  slivers: [
                    if(!hideAppBar && appBar != null) appBar!,
                    if (!hideAppBar && appBar == null) GeneralAppBar(showSwitch: showAppBarSwitcher,hideSearchBar: hideSearchBar,),
                    ...slivers,
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
