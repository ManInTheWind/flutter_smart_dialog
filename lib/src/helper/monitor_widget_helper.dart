import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/src/helper/dialog_proxy.dart';
import 'package:flutter_smart_dialog/src/util/log.dart';
import 'package:flutter_smart_dialog/src/util/view_utils.dart';

import '../data/dialog_info.dart';

class MonitorWidgetHelper {
  factory MonitorWidgetHelper() => instance;
  static MonitorWidgetHelper? _instance;

  static MonitorWidgetHelper get instance =>
      _instance ??= MonitorWidgetHelper._internal();

  late Queue<DialogInfo> monitorDialogQueue;

  bool prohibitMonitor = false;

  MonitorWidgetHelper._internal() {
    monitorDialogQueue = ListQueue();

    schedulerBinding.addPersistentFrameCallback((timeStamp) {
      if (monitorDialogQueue.isEmpty || prohibitMonitor) {
        return;
      }
      prohibitMonitor = true;
      var removeList = <DialogInfo>[];
      monitorDialogQueue.forEach((item) {
        try {
          var context = item.bindWidget;
          if (context == null) {
            throw Error();
          }
          _calculate(context, item);
        } catch (e) {
          removeList.add(item);
          SmartLog.d(
            "The element(hashcode: ${item.bindWidget.hashCode}) is recycled and"
            " the 'bindWidget' dialog dismiss automatically",
          );
        }
      });
      for (var i = removeList.length; i > 0; i--) {
        DialogProxy.instance.dismiss(
          status: SmartStatus.dialog,
          tag: removeList[i - 1].tag,
        );
      }
      prohibitMonitor = false;
    });
  }

  void _calculate(BuildContext context, DialogInfo item) {
    var renderObject = context.findRenderObject() as RenderBox?;
    if (renderObject == null) {
      throw Error();
    }

    handleDialog() {
      var selfOffset = renderObject.localToGlobal(Offset.zero);
      if (selfOffset.dx < 0 ||
          selfOffset.dy < 0 ||
          selfOffset.dx.isNaN ||
          selfOffset.dy.isNaN) {
        item.dialog.hide();
      } else {
        item.dialog.appear();
      }
    }

    var viewport = RenderAbstractViewport.of(renderObject);
    var revealedOffset = viewport?.getOffsetToReveal(renderObject, 0.0);
    if (revealedOffset != null) {
      // NonPage Scene
      handleDialog();
    } else {
      // Page Scene
      if (!item.bindPage) {
        handleDialog();
      }
    }
  }
}
