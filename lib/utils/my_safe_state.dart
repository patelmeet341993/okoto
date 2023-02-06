import 'package:flutter/material.dart';

mixin MySafeState<T extends StatefulWidget> on State<T> {
  bool _pageMounted = false;

  bool get pageMounted => _pageMounted;

  /// Call this method in the build of State
  @protected
  void pageBuild() {
    _pageMounted = false;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _pageMounted = true;
    });
  }

  /// Call this method to safely update the state
  @protected
  void mySetState() {
    try {
      if(!mounted) {
        return;
      }
    }
    catch(e) {
      return;
    }

    if(_pageMounted) {
      setState(() {});
    }
    else {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {});
      });
    }
  }
}