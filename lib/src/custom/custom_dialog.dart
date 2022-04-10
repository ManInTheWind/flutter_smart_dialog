import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/data/dialog_info.dart';
import 'package:flutter_smart_dialog/src/data/smart_tag.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';
import 'package:flutter_smart_dialog/src/widget/attach_dialog_widget.dart';

import '../../flutter_smart_dialog.dart';
import '../config/config.dart';
import '../config/enum_config.dart';
import '../data/base_dialog.dart';
import '../smart_dialog.dart';
import 'main_dialog.dart';

enum DialogType {
  dialog,
  custom,
  attach,
  allDialog,
  allCustom,
  allAttach,
}

///main function : custom dialog
class CustomDialog extends BaseDialog {
  CustomDialog({
    required Config config,
    required OverlayEntry overlayEntry,
  }) : super(config: config, overlayEntry: overlayEntry);

  static MainDialog? mainDialogSingle;

  DateTime? clickBgLastTime;

  Future<T?> show<T>({
    required Widget widget,
    required AlignmentGeometry alignment,
    required bool usePenetrate,
    required bool useAnimation,
    required Duration animationDuration,
    required SmartAnimationType animationType,
    required Color maskColor,
    required bool clickBgDismiss,
    required bool debounce,
    required Widget? maskWidget,
    required VoidCallback? onDismiss,
    required String? tag,
    required bool backDismiss,
    required bool keepSingle,
    required bool useSystem,
  }) {
    if (!_handleMustOperate(
      tag: tag,
      backDismiss: backDismiss,
      keepSingle: keepSingle,
      debounce: debounce,
      type: DialogType.custom,
      useSystem: useSystem,
    )) return Future.value(null);
    return mainDialog.show<T>(
      widget: widget,
      alignment: alignment,
      usePenetrate: usePenetrate,
      useAnimation: useAnimation,
      animationDuration: animationDuration,
      animationType: animationType,
      maskColor: maskColor,
      maskWidget: maskWidget,
      clickBgDismiss: clickBgDismiss,
      onDismiss: onDismiss,
      useSystem: useSystem,
      reuse: true,
      onBgTap: () {
        if (!_clickBgDebounce()) return;
        dismiss();
      },
    );
  }

  Future<T?>? showAttach<T>({
    required BuildContext? targetContext,
    required Offset? target,
    required Widget widget,
    required AlignmentGeometry alignment,
    required bool usePenetrate,
    required bool useAnimation,
    required Duration animationDuration,
    required SmartAnimationType animationType,
    required Color maskColor,
    required bool clickBgDismiss,
    required bool debounce,
    required Widget? maskWidget,
    required HighlightBuilder highlightBuilder,
    required VoidCallback? onDismiss,
    required String? tag,
    required bool backDismiss,
    required bool keepSingle,
    required bool useSystem,
  }) {
    if (!_handleMustOperate(
      tag: tag,
      backDismiss: backDismiss,
      keepSingle: keepSingle,
      debounce: debounce,
      type: DialogType.attach,
      useSystem: useSystem,
    )) return null;
    return mainDialog.showAttach<T>(
      targetContext: targetContext,
      target: target,
      widget: widget,
      alignment: alignment,
      usePenetrate: usePenetrate,
      useAnimation: useAnimation,
      animationDuration: animationDuration,
      animationType: animationType,
      maskColor: maskColor,
      highlightBuilder: highlightBuilder,
      maskWidget: maskWidget,
      clickBgDismiss: clickBgDismiss,
      onDismiss: onDismiss,
      useSystem: useSystem,
      onBgTap: () {
        if (!_clickBgDebounce()) return;
        dismiss();
      },
    );
  }

  bool _handleMustOperate({
    required String? tag,
    required bool backDismiss,
    required bool keepSingle,
    required bool debounce,
    required DialogType type,
    required bool useSystem,
  }) {
    // debounce
    if (!_checkDebounce(debounce, type)) return false;

    //handle dialog stack
    _handleDialogStack(
      tag: tag,
      backDismiss: backDismiss,
      keepSingle: keepSingle,
      type: type,
      useSystem: useSystem,
    );

    config.custom.isExist = DialogType.custom == type;
    config.attach.isExist = DialogType.attach == type;
    return true;
  }

  void _handleDialogStack({
    required String? tag,
    required bool backDismiss,
    required bool keepSingle,
    required DialogType type,
    required bool useSystem,
  }) {
    var proxy = DialogProxy.instance;

    if (keepSingle) {
      DialogInfo dialogInfo;
      if (_getDialog(DialogType.dialog, false, SmartTag.keepSingle) == null) {
        dialogInfo = DialogInfo(
          dialog: this,
          backDismiss: backDismiss,
          type: type,
          tag: SmartTag.keepSingle,
          useSystem: useSystem,
        );
        proxy.dialogQueue.add(dialogInfo);
        Overlay.of(DialogProxy.contextOverlay)!.insert(
          overlayEntry,
          below: proxy.entryLoading,
        );
        mainDialogSingle = mainDialog;
      }

      mainDialog = mainDialogSingle!;
      return;
    }

    // handle dialog stack
    var dialogInfo = DialogInfo(
      dialog: this,
      backDismiss: backDismiss,
      type: type,
      tag: tag,
      useSystem: useSystem,
    );
    proxy.dialogQueue.add(dialogInfo);
    // insert the dialog carrier into the page
    Overlay.of(DialogProxy.contextOverlay)!.insert(
      overlayEntry,
      below: proxy.entryLoading,
    );
  }

  bool _checkDebounce(bool debounce, DialogType type) {
    if (!debounce) return true;

    var proxy = DialogProxy.instance;
    var now = DateTime.now();
    var debounceTime = type == DialogType.dialog
        ? SmartDialog.config.custom.debounceTime
        : SmartDialog.config.attach.debounceTime;
    var isShake = proxy.dialogLastTime != null &&
        now.difference(proxy.dialogLastTime!) < debounceTime;
    proxy.dialogLastTime = now;
    if (isShake) return false;

    return true;
  }

  bool _clickBgDebounce() {
    var now = DateTime.now();
    var isShake = clickBgLastTime != null &&
        now.difference(clickBgLastTime!) < Duration(milliseconds: 500);
    clickBgLastTime = now;
    if (isShake) return false;

    return true;
  }

  static Future<void>? dismiss<T>([
    DialogType type = DialogType.dialog,
    bool back = false,
    String? tag,
    T? result,
  ]) {
    if (type == DialogType.dialog) {
      return _closeSingle<T>(DialogType.dialog, back, tag, result);
    } else if (type == DialogType.custom) {
      return _closeSingle<T>(DialogType.custom, back, tag, result);
    } else if (type == DialogType.attach) {
      return _closeSingle<T>(DialogType.attach, back, tag, result);
    } else if (type == DialogType.allDialog) {
      return _closeAll<T>(DialogType.dialog, back, tag, result);
    } else if (type == DialogType.allCustom) {
      return _closeAll<T>(DialogType.custom, back, tag, result);
    } else if (type == DialogType.allAttach) {
      return _closeAll<T>(DialogType.attach, back, tag, result);
    }
    return null;
  }

  static Future<void> _closeAll<T>(
    DialogType type,
    bool back,
    String? tag,
    T? result,
  ) async {
    for (int i = DialogProxy.instance.dialogQueue.length; i > 0; i--) {
      await _closeSingle(type, back, tag, result);
    }
  }

  static Future<void> _closeSingle<T>(
    DialogType type,
    bool back,
    String? tag,
    T? result,
  ) async {
    var info = _getDialog(type, back, tag);
    if (info == null) return;

    //handle close dialog
    var proxy = DialogProxy.instance;
    proxy.dialogQueue.remove(info);
    var customDialog = info.dialog;

    //check if the queue contains a custom dialog or attach dialog
    proxy.config.custom.isExist = false;
    proxy.config.attach.isExist = false;
    for (var item in proxy.dialogQueue) {
      if (item.type == DialogType.custom) {
        proxy.config.custom.isExist = true;
      } else if (item.type == DialogType.attach) {
        proxy.config.attach.isExist = true;
      }
    }

    //perform a real dismiss
    await customDialog.mainDialog.dismiss(useSystem: info.useSystem);
    customDialog.overlayEntry.remove();
  }

  static DialogInfo? _getDialog(DialogType type, bool back, String? tag) {
    var proxy = DialogProxy.instance;
    if (proxy.dialogQueue.isEmpty) return null;

    DialogInfo? info;
    var dialogQueue = proxy.dialogQueue;
    var list = dialogQueue.toList();

    for (var i = dialogQueue.length - 1; i >= 0; i--) {
      if (dialogQueue.isEmpty) break;
      var item = list[i];
      if (tag != null && item.tag == tag) {
        info = item;
        break;
      } else if (tag == null &&
          (type == DialogType.dialog || item.type == type)) {
        info = item;
        break;
      }
    }

    //handle prohibiting back event
    if (info != null && (!info.backDismiss && back)) return null;

    return info;
  }
}
