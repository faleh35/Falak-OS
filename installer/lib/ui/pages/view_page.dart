import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../models.dart';
import '../theme.dart';
import '../widgets.dart';

class ViewPage extends StatelessWidget {
  const ViewPage({super.key, required this.state});

  final InstallerState state;

  @override
  Widget build(BuildContext context) {
    final s = state.s;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(title: s.viewTitle, subtitle: s.viewBody),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 18.0;
              final columns = constraints.maxWidth > 760 ? 3 : 1;
              final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final v in DesktopView.values)
                    SizedBox(
                      width: width,
                      child: SelectableCard(
                        key: Key('view-${v.id}'),
                        selected: state.view == v,
                        onTap: () => state.setView(v),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AspectRatio(aspectRatio: 16 / 9, child: Image.asset(v.preview, fit: BoxFit.cover)),
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s.viewName(v), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  Text(s.viewDescription(v), style: const TextStyle(color: FalakColors.muted)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
