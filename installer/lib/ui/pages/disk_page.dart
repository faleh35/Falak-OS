import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../models.dart';
import '../theme.dart';
import '../widgets.dart';

class DiskPage extends StatelessWidget {
  const DiskPage({super.key, required this.state});

  final InstallerState state;

  @override
  Widget build(BuildContext context) {
    final s = state.s;
    final hasTpm = state.info?.hasTpm ?? false;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(title: s.diskTitle, subtitle: s.diskBody),
          WarningNote(text: s.diskWarning),
          const SizedBox(height: 20),
          if (state.loadingDisks)
            const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator())
          else if (state.disks.isEmpty)
            Text(s.diskNone, style: const TextStyle(color: FalakColors.muted))
          else
            for (final disk in state.disks) ...[
              _DiskTile(state: state, disk: disk),
              const SizedBox(height: 10),
            ],
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: state.loadingDisks ? null : state.refreshDisks,
              icon: const Icon(Icons.refresh),
              label: Text(s.diskRefresh),
            ),
          ),
          const SizedBox(height: 16),
          FalakCard(
            child: SwitchListTile(
              key: const Key('encrypt'),
              secondary: const Icon(Icons.lock_outline, color: FalakColors.teal),
              title: Text(s.encryptTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(hasTpm ? s.encryptBody : s.encryptNoTpm),
              value: state.encrypt,
              onChanged: hasTpm ? state.setEncrypt : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiskTile extends StatelessWidget {
  const _DiskTile({required this.state, required this.disk});

  final InstallerState state;
  final Disk disk;

  @override
  Widget build(BuildContext context) {
    final s = state.s;
    final selected = state.selectedDisk?.path == disk.path;
    final details = [
      disk.path,
      disk.sizeLabel,
      if (disk.transport.isNotEmpty) disk.transport.toUpperCase(),
      if (disk.removable) s.diskRemovable,
    ].join('  ·  ');
    return SelectableCard(
      key: Key('disk-${disk.name}'),
      selected: selected,
      enabled: disk.bigEnough,
      onTap: () => state.selectDisk(disk),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(disk.removable ? Icons.usb : Icons.storage, size: 32, color: selected ? FalakColors.gold : FalakColors.teal),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    disk.model.isEmpty ? disk.name : disk.model,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(details, textDirection: TextDirection.ltr, style: const TextStyle(color: FalakColors.muted)),
                  if (!disk.bigEnough) ...[
                    const SizedBox(height: 4),
                    Text(s.diskTooSmall, style: const TextStyle(color: FalakColors.danger)),
                  ],
                ],
              ),
            ),
            if (selected) const Icon(Icons.check_circle, color: FalakColors.gold),
          ],
        ),
      ),
    );
  }
}
