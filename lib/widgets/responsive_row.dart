import 'package:flutter/material.dart';

class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final List<int>? flexValues;
  final double spacing;
  final CrossAxisAlignment crossAxisAlignment;
  final double breakpoint;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.flexValues,
    this.spacing = 24,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.breakpoint = 900,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > breakpoint;
        if (isDesktop) {
          final rowChildren = <Widget>[];
          for (int i = 0; i < children.length; i++) {
            if (i > 0 && spacing > 0) {
              rowChildren.add(SizedBox(width: spacing));
            }
            final flex = (flexValues != null && i < flexValues!.length) ? flexValues![i] : 1;
            rowChildren.add(Expanded(flex: flex, child: children[i]));
          }
          return Row(
            crossAxisAlignment: crossAxisAlignment,
            children: rowChildren,
          );
        } else {
          final colChildren = <Widget>[];
          for (int i = 0; i < children.length; i++) {
            if (i > 0 && spacing > 0) {
              colChildren.add(SizedBox(height: spacing));
            }
            colChildren.add(children[i]);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: colChildren,
          );
        }
      },
    );
  }
}
