import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../theme.dart';
import '../widgets.dart';

class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key, required this.state});

  final InstallerState state;

  @override
  Widget build(BuildContext context) {
    final s = state.s;
    final disk = state.selectedDisk;
    final company = state.companySetup;
    final rows = <(IconData, String, String)>[
      (
        Icons.storage,
        s.summaryDisk,
        disk == null ? '-' : '${disk.model.isEmpty ? disk.name : disk.model}  (${disk.path}, ${disk.sizeLabel})',
      ),
      (Icons.lock_outline, s.summaryEncryption, state.encrypt ? s.yes : s.no),
      (Icons.dashboard_outlined, s.summaryView, s.viewName(state.view)),
      (
        Icons.person_outline,
        s.summaryAccount,
        '${state.fullName.text.trim()}  (${state.username.text})  ·  ${state.hostname.text}',
      ),
      (Icons.translate, s.summaryLanguage, '${s.languageName}  ·  ${state.timezone}'),
      if (state.showCompanyStep)
        (
          Icons.business_outlined,
          s.summaryCompany,
          company == null ? s.summaryCompanyNone : '${company.configUrl}  ·  ${company.profile}',
        ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(title: s.summaryTitle, subtitle: s.summaryBody),
              FalakCard(
                child: Column(
                  children: [
                    for (final (icon, label, value) in rows)
                      ListTile(
                        leading: Icon(icon, color: FalakColors.teal),
                        title: Text(label, style: const TextStyle(color: FalakColors.muted, fontSize: 13)),
                        subtitle: Text(value, style: const TextStyle(color: FalakColors.text, fontSize: 15)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              WarningNote(text: s.diskWarning, color: FalakColors.danger),
              const SizedBox(height: 8),
              CheckboxListTile(
                key: const Key('eraseConfirm'),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: state.eraseConfirmed,
                onChanged: (v) => state.setEraseConfirmed(v ?? false),
                title: Text(s.eraseConfirm),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
