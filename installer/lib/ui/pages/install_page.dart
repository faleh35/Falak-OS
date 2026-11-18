import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../system/install_backend.dart';
import '../theme.dart';
import '../widgets.dart';

class InstallPage extends StatefulWidget {
  const InstallPage({super.key, required this.state});

  final InstallerState state;

  @override
  State<InstallPage> createState() => _InstallPageState();
}

class _InstallPageState extends State<InstallPage> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final s = state.s;
    final theme = Theme.of(context);

    if (state.finished) {
      return _Finished(state: state);
    }

    final phases = [
      (InstallPhase.prepare, s.phasePrepare),
      (InstallPhase.download, s.phaseDownload),
      (InstallPhase.install, s.phaseInstall),
      (InstallPhase.settings, s.phaseSettings),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(title: s.installingTitle),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: state.progress,
              minHeight: 10,
              color: state.installError == null ? FalakColors.teal : FalakColors.danger,
              backgroundColor: const Color(0xFF232B5C),
            ),
          ),
          const SizedBox(height: 8),
          Text('${(state.progress * 100).round()}%', style: const TextStyle(color: FalakColors.muted)),
          const SizedBox(height: 20),
          for (final (phase, label) in phases)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  _PhaseIcon(current: state.phase, phase: phase, failed: state.installError != null),
                  const SizedBox(width: 12),
                  Text(label, style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
          if (state.installError != null) ...[
            const SizedBox(height: 20),
            WarningNote(text: '${s.installFailed}\n${state.installError}', color: FalakColors.danger),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: [
                FilledButton.icon(
                  key: const Key('retry'),
                  onPressed: state.retryInstall,
                  icon: const Icon(Icons.refresh),
                  label: Text(s.retry),
                ),
                TextButton(onPressed: state.backToSummary, child: Text(s.back)),
              ],
            ),
          ],
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: () => setState(() => _showDetails = !_showDetails),
            icon: Icon(_showDetails ? Icons.expand_less : Icons.expand_more),
            label: Text(_showDetails ? s.hideDetails : s.showDetails),
          ),
          if (_showDetails)
            Container(
              height: 240,
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF070A1C),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: FalakColors.panelBorder),
              ),
              child: SingleChildScrollView(
                reverse: true,
                child: Text(
                  state.log.join('\n'),
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: FalakColors.muted),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PhaseIcon extends StatelessWidget {
  const _PhaseIcon({required this.current, required this.phase, required this.failed});

  final InstallPhase current;
  final InstallPhase phase;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    if (current.index > phase.index) {
      return const Icon(Icons.check_circle, color: FalakColors.gold, size: 22);
    }
    if (current == phase) {
      if (failed) return const Icon(Icons.error, color: FalakColors.danger, size: 22);
      return const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5));
    }
    return const Icon(Icons.radio_button_unchecked, color: FalakColors.panelBorder, size: 22);
  }
}

class _Finished extends StatelessWidget {
  const _Finished({required this.state});

  final InstallerState state;

  @override
  Widget build(BuildContext context) {
    final s = state.s;
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/falakos-logo.png', width: 120, height: 120),
            const SizedBox(height: 24),
            Text(s.doneTitle, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Text(
              state.dryRun ? s.doneDryRun : s.doneBody,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(color: FalakColors.muted),
            ),
            const SizedBox(height: 8),
            Text(s.tagline, style: theme.textTheme.titleMedium?.copyWith(color: FalakColors.gold, fontStyle: FontStyle.italic)),
            const SizedBox(height: 28),
            FilledButton.icon(
              key: const Key('reboot'),
              onPressed: state.reboot,
              icon: const Icon(Icons.restart_alt),
              label: Text(s.restart),
            ),
          ],
        ),
      ),
    );
  }
}
