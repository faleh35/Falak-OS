import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../theme.dart';
import '../widgets.dart';

class CompanyPage extends StatelessWidget {
  const CompanyPage({super.key, required this.state});

  final InstallerState state;

  @override
  Widget build(BuildContext context) {
    final s = state.s;
    final setup = state.companySetup;
    final showError = state.companyEnabled &&
        state.companyConfig.text.isNotEmpty &&
        !(setup?.isComplete ?? false);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(title: s.companyTitle, subtitle: s.companyBody),
              FalakCard(
                child: SwitchListTile(
                  key: const Key('companyToggle'),
                  secondary: const Icon(Icons.business_outlined, color: FalakColors.teal),
                  title: Text(s.companyToggle, style: const TextStyle(fontWeight: FontWeight.w600)),
                  value: state.companyEnabled,
                  onChanged: state.setCompanyEnabled,
                ),
              ),
              if (state.companyEnabled) ...[
                const SizedBox(height: 20),
                TextField(
                  key: const Key('companyConfig'),
                  controller: state.companyConfig,
                  textDirection: TextDirection.ltr,
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    labelText: s.companyConfig,
                    hintText: s.companyConfigHint,
                    errorText: showError ? s.errCompanyConfig : null,
                    prefixIcon: const Icon(Icons.link),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  key: const Key('companyProfile'),
                  controller: state.companyProfile,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    labelText: s.companyProfile,
                    hintText: s.companyProfileHint,
                    prefixIcon: const Icon(Icons.badge_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  key: const Key('companyOtp'),
                  controller: state.companyOtp,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    labelText: s.companyOtp,
                    hintText: s.companyOtpHint,
                    prefixIcon: const Icon(Icons.key_outlined),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Text(s.companyLater, style: const TextStyle(color: FalakColors.muted)),
            ],
          ),
        ),
      ),
    );
  }
}
