import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/helper/navigator_observer.dart';
import 'package:flutter_smart_dialog/src/util/view_utils.dart';
import 'package:flutter_smart_dialog/src/widget/toast_widget.dart';

import 'helper/dialog_proxy.dart';
import 'helper/pop_monitor/boost_route_monitor.dart';
import 'helper/pop_monitor/monitor_pop_route.dart';
import 'widget/loading_widget.dart';

typedef FlutterSmartToastBuilder = Widget Function(String msg);
typedef FlutterSmartLoadingBuilder = Widget Function(String msg);
typedef FlutterSmartStyleBuilder = Widget Function(Widget child);

class FlutterSmartDialog extends StatefulWidget {
  FlutterSmartDialog({
    Key? key,
    required this.child,
    this.toastBuilder,
    this.loadingBuilder,
    this.styleBuilder,
  }) : super(key: key);

  final Widget? child;

  ///set default toast widget
  final FlutterSmartToastBuilder? toastBuilder;

  ///set default loading widget
  final FlutterSmartLoadingBuilder? loadingBuilder;

  ///Compatible with cupertino style
  final FlutterSmartStyleBuilder? styleBuilder;

  @override
  _FlutterSmartDialogState createState() => _FlutterSmartDialogState();

  static final observer = SmartNavigatorObserver();

  ///Compatible with flutter_boost
  static Route<dynamic>? boostMonitor(Route<dynamic>? route) =>
      BoostRouteMonitor.instance.push(route);

  ///recommend the way of init
  static TransitionBuilder init({
    TransitionBuilder? builder,
    //set default toast widget
    FlutterSmartToastBuilder? toastBuilder,
    //set default loading widget
    FlutterSmartLoadingBuilder? loadingBuilder,
    //Compatible with cupertino style
    FlutterSmartStyleBuilder? styleBuilder,
  }) {
    MonitorPopRoute.instance;

    return (BuildContext context, Widget? child) {
      return builder == null
          ? FlutterSmartDialog(
              toastBuilder: toastBuilder,
              loadingBuilder: loadingBuilder,
              styleBuilder: styleBuilder,
              child: child,
            )
          : builder(
              context,
              FlutterSmartDialog(
                toastBuilder: toastBuilder,
                loadingBuilder: loadingBuilder,
                styleBuilder: styleBuilder,
                child: child,
              ),
            );
    };
  }
}

class _FlutterSmartDialogState extends State<FlutterSmartDialog> {
  @override
  void initState() {
    ViewUtils.addSafeUse(() {
      try {
        var navigator = widget.child as Navigator;
        var key = navigator.key as GlobalKey;
        DialogProxy.contextNavigator = key.currentContext;
      } catch (e) {}
    });

    var proxy = DialogProxy.instance;
    // solve Flutter Inspector -> select widget mode function failure problem
    proxy.initialize();
    defaultToast(String msg) {
      return ToastWidget(msg: msg);
    }

    defaultLoading(String msg) {
      return LoadingWidget(msg: msg);
    }

    proxy.toastBuilder = widget.toastBuilder ?? defaultToast;
    proxy.loadingBuilder = widget.loadingBuilder ?? defaultLoading;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.styleBuilder == null
        ? Material(color: Colors.transparent, child: _buildOverlay())
        : widget.styleBuilder!.call(_buildOverlay());
  }

  Widget _buildOverlay() {
    return Overlay(initialEntries: [
      //main layout
      OverlayEntry(
        builder: (BuildContext context) => widget.child ?? Container(),
      ),

      //provided separately for custom dialog
      OverlayEntry(builder: (BuildContext context) {
        DialogProxy.contextOverlay = context;
        return Container();
      }),

      //provided separately for loading
      DialogProxy.instance.entryLoading,

      //provided separately for toast
      DialogProxy.instance.entryToast,
    ]);
  }
}
