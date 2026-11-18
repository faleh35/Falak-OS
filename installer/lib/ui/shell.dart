import 'package:flutter/material.dart';

import '../app_state.dart';
import 'pages/account_page.dart';
import 'pages/company_page.dart';
import 'pages/disk_page.dart';
import 'pages/install_page.dart';
import 'pages/summary_page.dart';
import 'pages/view_page.dart';
import 'pages/welcome_page.dart';
import 'theme.dart';
import 'widgets.dart';

/// The installer window: step rail on one side, the current page and the buttons on the other.
class InstallerShell extends StatelessWidget {
  const InstallerShell({super.key, required this.state});

  final InstallerState state;

  @override
  Widget build(BuildContext context) {
    // The route content is cached by the Navigator, so listen here as well.
    return ListenableBuilder(listenable: state, builder: (context, _) => _build(context));
  }

  Widget _build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: NightSky()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(width: 250, child: StepRail(state: state)),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (state.dryRun) _DryRunBanner(text: state.s.dryRunBanner),
                        Expanded(
                          child: FalakPanel(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              // Pages fill the panel (the default layout would center them).
                              layoutBuilder: (current, previous) => Stack(
                                fit: StackFit.expand,
                                children: [...previous, if (current != null) current],
                              ),
                              child: KeyedSubtree(key: ValueKey(state.step), child: _page()),
                            ),
                          ),
                        ),
                        if (state.step != InstallerStep.install) _NavBar(state: state),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _page() {
    switch (state.step) {
      case InstallerStep.welcome:
        return WelcomePage(state: state);
      case InstallerStep.view:
        return ViewPage(state: state);
      case InstallerStep.disk:
        return DiskPage(state: state);
      case InstallerStep.account:
        return AccountPage(state: state);
      case InstallerStep.company:
        return CompanyPage(state: state);
      case InstallerStep.summary:
        return SummaryPage(state: state);
      case InstallerStep.install:
        return InstallPage(state: state);
    }
  }
}

class StepRail extends StatelessWidget {
  const StepRail({super.key, required this.state});

  final InstallerState state;

  String _label(InstallerStep step) {
    final s = state.s;
    switch (step) {
      case InstallerStep.welcome:
        return s.stepWelcome;
      case InstallerStep.view:
        return s.stepView;
      case InstallerStep.disk:
        return s.stepDisk;
      case InstallerStep.account:
        return s.stepAccount;
      case InstallerStep.company:
        return s.stepCompany;
      case InstallerStep.summary:
        return s.stepSummary;
      case InstallerStep.install:
        return s.stepInstall;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = state.s;
    final steps = state.steps;
    final current = state.stepIndex;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Image.asset('assets/falakos-logo.png', width: 48, height: 48),
            const SizedBox(width: 12),
            const Text(
              'FalakOS',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: FalakColors.text),
            ),
          ],
        ),
        if (state.info != null) ...[
          const SizedBox(height: 6),
          Text(s.editionName(state.info!.edition), style: const TextStyle(color: FalakColors.gold)),
        ],
        const SizedBox(height: 36),
        for (var i = 0; i < steps.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                _StepDot(index: i, current: current),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _label(steps[i]),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: i == current ? FontWeight.w700 : FontWeight.w500,
                      color: i <= current ? FalakColors.text : FalakColors.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const Spacer(),
        Text(
          s.tagline,
          style: const TextStyle(color: FalakColors.muted, fontStyle: FontStyle.italic, fontSize: 13),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.index, required this.current});

  final int index;
  final int current;

  @override
  Widget build(BuildContext context) {
    final done = index < current;
    final active = index == current;
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? FalakColors.gold : (active ? FalakColors.teal : Colors.transparent),
        border: Border.all(color: done || active ? Colors.transparent : FalakColors.panelBorder, width: 2),
      ),
      child: done
          ? const Icon(Icons.check, size: 16, color: FalakColors.night)
          : Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: active ? FalakColors.night : FalakColors.muted,
              ),
            ),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar({required this.state});

  final InstallerState state;

  @override
  Widget build(BuildContext context) {
    final s = state.s;
    final isSummary = state.step == InstallerStep.summary;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          if (state.canGoBack)
            TextButton.icon(
              key: const Key('back'),
              onPressed: state.back,
              icon: const BackButtonIcon(),
              label: Text(s.back),
            ),
          const Spacer(),
          FilledButton(
            key: const Key('next'),
            style: isSummary ? FilledButton.styleFrom(backgroundColor: FalakColors.gold) : null,
            onPressed: state.canContinue ? state.next : null,
            child: Text(isSummary ? s.install : s.next),
          ),
        ],
      ),
    );
  }
}

class _DryRunBanner extends StatelessWidget {
  const _DryRunBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x33F5B942),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: FalakColors.gold),
      ),
      child: Row(
        children: [
          const Icon(Icons.science_outlined, color: FalakColors.gold),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(color: FalakColors.gold, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
