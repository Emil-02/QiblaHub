import 'package:flutter/material.dart';

import '../data/team_data.dart';
import '../theme.dart';
import 'common.dart';

class DevelopmentTeamCard extends StatelessWidget {
  final String Function(String key) translate;
  final VoidCallback onTap;

  const DevelopmentTeamCard({
    super.key,
    required this.translate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final studentCount = translate(
      TeamData.studentCountKey,
    ).replaceFirst('{count}', '${TeamData.members.length}');

    return Semantics(
      button: true,
      label: translate(TeamData.titleKey),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SoftIcon(
                      Icons.groups_rounded,
                      color: QhColors.primary,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            translate(TeamData.titleKey),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${translate(TeamData.projectKey)} — ${translate(TeamData.groupKey)}',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: colorScheme.outlineVariant),
                const SizedBox(height: 12),
                Text(
                  translate(TeamData.supervisedByKey).toUpperCase(),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.school_outlined,
                      size: 19,
                      color: QhColors.gold,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        TeamData.lecturer,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          height: 1.4,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      studentCount,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: onTap,
                      iconAlignment: IconAlignment.end,
                      icon: const Icon(Icons.chevron_right, size: 18),
                      label: Text(translate(TeamData.viewTeamKey)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
