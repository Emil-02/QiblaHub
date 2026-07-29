import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/team_data.dart';
import '../theme.dart';
import 'common.dart';

typedef ExternalUrlLauncher = Future<bool> Function(Uri uri);

Future<void> showDevelopmentTeamSheet(
  BuildContext context, {
  required String Function(String key) translate,
  ExternalUrlLauncher? externalUrlLauncher,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    clipBehavior: Clip.antiAlias,
    builder: (sheetContext) => DevelopmentTeamSheet(
      translate: translate,
      externalUrlLauncher: externalUrlLauncher,
    ),
  );
}

class DevelopmentTeamSheet extends StatelessWidget {
  final String Function(String key) translate;
  final ExternalUrlLauncher? externalUrlLauncher;

  const DevelopmentTeamSheet({
    super.key,
    required this.translate,
    this.externalUrlLauncher,
  });

  Future<bool> _openExternally(Uri uri) {
    final launcher = externalUrlLauncher;
    if (launcher != null) return launcher(uri);
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openUrl(
    BuildContext context,
    Uri uri,
    String errorMessage,
  ) async {
    var opened = false;
    try {
      opened = await _openExternally(uri);
    } catch (_) {
      opened = false;
    }

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.86,
      minChildSize: 0.55,
      maxChildSize: 0.96,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SoftIcon(
                Icons.groups_rounded,
                color: QhColors.primary,
                size: 48,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      translate(TeamData.titleKey),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${translate(TeamData.projectKey)} — ${translate(TeamData.groupKey)}',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: translate('close'),
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _sectionLabel(context, translate(TeamData.lecturerLabelKey)),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: const CircleAvatar(
                backgroundColor: QhColors.goldLight,
                foregroundColor: QhColors.goldDark,
                child: Icon(Icons.school_outlined),
              ),
              title: const Text(
                TeamData.lecturer,
                style: TextStyle(fontWeight: FontWeight.w700, height: 1.35),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _sectionLabel(context, translate(TeamData.studentsLabelKey)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                for (final (index, member) in TeamData.members.indexed) ...[
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 5,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: QhColors.primary.withValues(alpha: 0.12),
                      foregroundColor: QhColors.primary,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    title: Text(
                      member.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                    subtitle: Text(
                      member.studentId,
                      style: const TextStyle(
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  if (index < TeamData.members.length - 1)
                    const Divider(height: 1, indent: 72),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _openUrl(
                context,
                TeamData.downloadUri,
                translate(TeamData.downloadErrorKey),
              ),
              icon: const Icon(Icons.download_rounded),
              label: Text(translate(TeamData.downloadLabelKey)),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: () => _openUrl(
                context,
                TeamData.sourceCodeUri,
                translate(TeamData.sourceErrorKey),
              ),
              icon: const Icon(Icons.code_rounded),
              label: Text(translate(TeamData.sourceLabelKey)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String label) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
