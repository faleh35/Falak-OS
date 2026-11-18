import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../models.dart';
import '../theme.dart';
import '../widgets.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key, required this.state});

  final InstallerState state;

  @override
  Widget build(BuildContext context) {
    final s = state.s;
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset('assets/falakos-logo.png', width: 96, height: 96),
          const SizedBox(height: 20),
          Text(s.welcomeTitle, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            s.tagline,
            style: theme.textTheme.titleMedium?.copyWith(color: FalakColors.gold, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(s.welcomeBody, style: theme.textTheme.bodyLarge?.copyWith(color: FalakColors.muted)),
          ),
          const SizedBox(height: 32),
          Text(s.chooseLanguage, style: theme.textTheme.titleSmall),
          const SizedBox(height: 10),
          SegmentedButton<AppLanguage>(
            key: const Key('language'),
            segments: const [
              ButtonSegment(value: AppLanguage.en, label: Text('English')),
              ButtonSegment(value: AppLanguage.ar, label: Text('العربية')),
            ],
            selected: {state.language},
            onSelectionChanged: (value) => state.setLanguage(value.first),
          ),
          const SizedBox(height: 32),
          if (state.loadError != null)
            WarningNote(text: state.loadError!, color: FalakColors.danger)
          else if (!state.loaded)
            const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 3))
          else
            Chip(
              avatar: const Icon(Icons.verified_outlined, size: 18, color: FalakColors.teal),
              label: Text('${s.editionLabel}: ${s.editionName(state.info!.edition)}'),
            ),
        ],
      ),
    );
  }
}
