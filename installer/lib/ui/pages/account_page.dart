import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../models.dart';
import '../widgets.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key, required this.state});

  final InstallerState state;

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final s = state.s;

    String? usernameError() {
      if (state.username.text.isEmpty) return null;
      return switch (state.usernameProblem) {
        UsernameProblem.invalid => s.errUsernameInvalid,
        UsernameProblem.reserved => s.errUsernameReserved,
        _ => null,
      };
    }

    String? passwordError() {
      if (state.password.text.isEmpty) return null;
      return state.password.text.length < 8 ? s.errPasswordShort : null;
    }

    String? confirmError() {
      if (state.confirmPassword.text.isEmpty) return null;
      return state.passwordProblem == PasswordProblem.mismatch ? s.errPasswordMismatch : null;
    }

    final timezones = {...commonTimezones, state.timezone}.toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(title: s.accountTitle, subtitle: s.accountBody),
              TextField(
                key: const Key('fullName'),
                controller: state.fullName,
                decoration: InputDecoration(labelText: s.fullName, prefixIcon: const Icon(Icons.person_outline)),
                onChanged: state.onFullNameEdited,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextField(
                key: const Key('username'),
                controller: state.username,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: s.username,
                  helperText: s.usernameHint,
                  errorText: usernameError(),
                  prefixIcon: const Icon(Icons.alternate_email),
                ),
                onChanged: state.onUsernameEdited,
              ),
              const SizedBox(height: 16),
              TextField(
                key: const Key('password'),
                controller: state.password,
                obscureText: !_showPassword,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: s.password,
                  errorText: passwordError(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                key: const Key('confirmPassword'),
                controller: state.confirmPassword,
                obscureText: !_showPassword,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: s.confirmPassword,
                  errorText: confirmError(),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                key: const Key('hostname'),
                controller: state.hostname,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: s.computerName,
                  errorText: state.hostname.text.isEmpty || state.hostnameOk ? null : s.errHostname,
                  prefixIcon: const Icon(Icons.computer),
                ),
                onChanged: state.onHostnameEdited,
              ),
              const SizedBox(height: 16),
              InputDecorator(
                decoration: InputDecoration(labelText: s.timezone, prefixIcon: const Icon(Icons.public)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    key: const Key('timezone'),
                    value: state.timezone,
                    isExpanded: true,
                    isDense: true,
                    items: [
                      for (final tz in timezones)
                        DropdownMenuItem(value: tz, child: Text(tz, textDirection: TextDirection.ltr)),
                    ],
                    onChanged: (tz) {
                      if (tz != null) state.setTimezone(tz);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
