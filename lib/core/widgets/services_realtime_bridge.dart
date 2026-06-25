import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/home/services_controller.dart';

/// App lifecycle: revalidate catalog on resume (fintech — not tight interval polling).
class ServicesRealtimeBridge extends StatefulWidget {
  const ServicesRealtimeBridge({super.key, required this.child});

  final Widget child;

  @override
  State<ServicesRealtimeBridge> createState() => _ServicesRealtimeBridgeState();
}

class _ServicesRealtimeBridgeState extends State<ServicesRealtimeBridge>
    with WidgetsBindingObserver {
  ServicesController? _services;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _bind(true));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _services ??= context.read<ServicesController>();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final inForeground = state == AppLifecycleState.resumed;
    _services?.setForeground(inForeground);
  }

  void _bind(bool inForeground) {
    if (!mounted) return;
    _services ??= context.read<ServicesController>();
    _services?.setForeground(inForeground);
  }

  @override
  void dispose() {
    _services?.setForeground(false);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
