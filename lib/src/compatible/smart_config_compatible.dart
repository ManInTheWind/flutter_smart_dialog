import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

///全局配置统一在此处处理
class SmartConfigCompatible {
  /// control the location of the dialog on the screen
  ///
  /// center: the dialog locate the center on the screen，the animation type is selected by the 'isLoading' param：
  /// true（the opacity animation），false（the scale transition animation）
  ///
  /// bottomCenter、bottomLeft、bottomRight：the dialog locate the bottom on the screen，
  /// animation effect is bottom-to-up
  ///
  /// topCenter、topLeft、Alignment.topRight：the dialog locate the top on the screen，
  /// animation effect is up-to-bottom
  ///
  /// centerLeft：the dialog locate the left on the screen，animation effect is left-to-right
  ///
  /// centerRight：the dialog locate the right on the screen，animation effect is right-to-left
  ///
  /// -------------------------------------------------------------------------------
  ///
  /// 控制dialog位于屏幕的位置
  ///
  /// center: dialog位于屏幕中间，动画可选，可使用isLoading选择：true（渐隐），false（缩放）
  ///
  /// bottomCenter、bottomLeft、bottomRight：dialog位于屏幕底部，动画默认为位移动画，自下而上
  ///
  /// topCenter、topLeft、Alignment.topRight：dialog位于屏幕顶部，
  ///
  /// centerLeft：dialog位于屏幕左边，动画默认为位移动画，自左而右，
  ///
  /// centerRight：dialog位于屏幕左边，动画默认为位移动画，自右而左，
  AlignmentGeometry alignment = Alignment.center;

  /// the animation duration can be adjusted by the [animationDuration] param；
  /// default（true），true（use the opacity animation），false（use the scale transition animation）
  ///
  /// 可使用[animationDuration]设置动画时间；
  /// 是否使用loading动画（默认：true，仅仅针对中间位置的dialog）；true:使用渐隐动画  false：使用缩放动画，
  bool isLoading = true;
  Duration animationDuration = Duration(milliseconds: 260);

  /// default（true），true（use the animation），false（not use）
  ///
  /// 是否使用动画（默认：true）
  bool isUseAnimation = true;

  /// default（false），true（click event will penetrate background），false（not penetration）
  ///
  /// 屏幕上交互事件可以穿透遮罩背景（默认:false）：true（交互事件能穿透背景，遮罩会自动变成透明），false（不能穿透）
  bool isPenetrate = false;

  /// the color of the mask，it is invalid if [isPenetrate] is true or [maskWidget] set the value
  ///
  /// 遮罩颜色：[isPenetrate]设置为true或[maskWidget]参数设置了数据，该参数会失效
  Color maskColor = Colors.black.withOpacity(0.35);

  /// highly customizable mask, it is invalid if [isPenetrate] is true
  ///
  /// 遮罩Widget，可高度自定义你自己的遮罩背景：[isPenetrate]设置为true，该参数失效
  Widget? maskWidget;

  /// default（true），true（loading will be closed after click background），false（not close）
  ///
  /// 点击遮罩，是否关闭dialog（默认：true）：true（点击遮罩关闭dialog），false（不关闭）
  bool clickBgDismiss = true;

  /// debounce feature，it works on toast and dialog：default（false）;
  /// you can use the [debounceTime] param to set the debounce time
  ///
  /// 防抖功能（debounce），它作用于toast和dialog上：默认（false）;
  /// 可以通过[debounceTime]参数设置防抖时间
  bool debounce = false;
  Duration debounceTime = Duration(milliseconds: 300);

  /// whether custom dialog，attach and loading  exist on the screen
  ///
  /// 自定义dialog，attach或loading，是否存在在界面上
  bool get isExist =>
      SmartDialog.config.custom.isExist ||
      SmartDialog.config.attach.isExist ||
      SmartDialog.config.loading.isExist;

  /// whether custom dialog exist on the screen
  ///
  /// 自定义dialog或attach是否存在在界面上
  bool get isExistMain =>
      SmartDialog.config.custom.isExist || SmartDialog.config.attach.isExist;

  /// whether loading exist on the screen
  ///
  /// loading是否存在界面上
  bool get isExistLoading => SmartDialog.config.loading.isExist;

  /// whether toast exist on the screen
  ///
  /// toast是否存在在界面上
  bool get isExistToast => SmartDialog.config.toast.isExist;
}
