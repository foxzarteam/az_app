import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/home/services_controller.dart';

/// Pull-to-refresh wrapper — standard fintech pattern for catalog screens.
class ServicesRefreshScroll extends StatelessWidget {
  const ServicesRefreshScroll({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      onRefresh: () => context.read<ServicesController>().pullToRefresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}
