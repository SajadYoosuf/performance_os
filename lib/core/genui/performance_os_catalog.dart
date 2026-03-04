import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_text_styles.dart';

/// Performance OS custom widget catalog for GenUI.
///
/// Defines the "vocabulary" of widgets that the AI agent can use
/// to dynamically render Performance OS UI components.
class PerformanceOSCatalog {
  PerformanceOSCatalog._();

  /// Returns the full catalog including core items + custom items.
  static Catalog asCatalog() {
    return CoreCatalogItems.asCatalog().copyWith([
      scoreCardItem,
      insightCardItem,
      motivationBannerItem,
      metricRowItem,
      actionSuggestionItem,
    ]);
  }

  /// Helper to extract a map from CatalogItemContext data.
  static Map<String, Object?> _dataMap(CatalogItemContext ctx) =>
      ctx.data as Map<String, Object?>;

  // ── ScoreCard ──
  static final scoreCardItem = CatalogItem(
    name: 'ScoreCard',
    dataSchema: S.object(
      properties: {
        'title': S.string(description: 'Title of the score metric'),
        'score': S.string(description: 'Score value (e.g. "94.8%")'),
        'trend': S.string(description: 'Trend indicator (e.g. "+2.4%")'),
        'trendDirection': S.string(
          description: 'up or down',
          enumValues: ['up', 'down'],
        ),
      },
      required: ['title', 'score'],
    ),
    widgetBuilder: (context) {
      final d = _dataMap(context);
      final titleN = context.dataContext.subscribeToString(
        d['title'] as Map<String, Object?>?,
      );
      final scoreN = context.dataContext.subscribeToString(
        d['score'] as Map<String, Object?>?,
      );
      final trendN = context.dataContext.subscribeToString(
        d['trend'] as Map<String, Object?>?,
      );
      final trendDirN = context.dataContext.subscribeToString(
        d['trendDirection'] as Map<String, Object?>?,
      );
      return ValueListenableBuilder<String?>(
        valueListenable: titleN,
        builder:
            (ctx, title, _) => ValueListenableBuilder<String?>(
              valueListenable: scoreN,
              builder:
                  (ctx, score, _) => ValueListenableBuilder<String?>(
                    valueListenable: trendN,
                    builder:
                        (ctx, trend, _) => ValueListenableBuilder<String?>(
                          valueListenable: trendDirN,
                          builder: (ctx, trendDir, _) {
                            final isUp = trendDir != 'down';
                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title ?? '',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        score ?? '0',
                                        style: AppTextStyles.heading2.copyWith(
                                          fontSize: 24,
                                        ),
                                      ),
                                      if (trend != null) ...[
                                        const SizedBox(width: 8),
                                        Icon(
                                          isUp
                                              ? Icons.trending_up
                                              : Icons.trending_down,
                                          color:
                                              isUp
                                                  ? AppColors.accentGreen
                                                  : AppColors.error,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          trend,
                                          style: AppTextStyles.caption.copyWith(
                                            color:
                                                isUp
                                                    ? AppColors.accentGreen
                                                    : AppColors.error,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                  ),
            ),
      );
    },
  );

  // ── InsightCard ──
  static final insightCardItem = CatalogItem(
    name: 'InsightCard',
    dataSchema: S.object(
      properties: {
        'title': S.string(description: 'Insight title'),
        'description': S.string(description: 'Detailed insight text'),
        'type': S.string(
          description: 'Type',
          enumValues: ['behavioral', 'suggestion', 'warning', 'positive'],
        ),
      },
      required: ['title', 'description'],
    ),
    widgetBuilder: (context) {
      final d = _dataMap(context);
      final titleN = context.dataContext.subscribeToString(
        d['title'] as Map<String, Object?>?,
      );
      final descN = context.dataContext.subscribeToString(
        d['description'] as Map<String, Object?>?,
      );
      final typeN = context.dataContext.subscribeToString(
        d['type'] as Map<String, Object?>?,
      );
      return ValueListenableBuilder<String?>(
        valueListenable: titleN,
        builder:
            (ctx, title, _) => ValueListenableBuilder<String?>(
              valueListenable: descN,
              builder:
                  (ctx, desc, _) => ValueListenableBuilder<String?>(
                    valueListenable: typeN,
                    builder: (ctx, type, _) {
                      final color = switch (type) {
                        'warning' => AppColors.error,
                        'positive' => AppColors.accentGreen,
                        'suggestion' => AppColors.accentOrange,
                        _ => Theme.of(ctx).colorScheme.primary,
                      };
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: color.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  color: color,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    title ?? '',
                                    style: AppTextStyles.labelLarge.copyWith(
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              desc ?? '',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            ),
      );
    },
  );

  // ── MotivationBanner ──
  static final motivationBannerItem = CatalogItem(
    name: 'MotivationBanner',
    dataSchema: S.object(
      properties: {'message': S.string(description: 'Motivational message')},
      required: ['message'],
    ),
    widgetBuilder: (context) {
      final d = _dataMap(context);
      final msgN = context.dataContext.subscribeToString(
        d['message'] as Map<String, Object?>?,
      );
      return ValueListenableBuilder<String?>(
        valueListenable: msgN,
        builder: (ctx, msg, _) {
          final primary = Theme.of(ctx).colorScheme.primary;
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primary.withValues(alpha: 0.1),
                  AppColors.accentGreen.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    msg ?? '',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );

  // ── MetricRow ──
  static final metricRowItem = CatalogItem(
    name: 'MetricRow',
    dataSchema: S.object(
      properties: {
        'label': S.string(description: 'Metric label'),
        'value': S.string(description: 'Metric value'),
        'change': S.string(description: 'Change percentage'),
      },
      required: ['label', 'value'],
    ),
    widgetBuilder: (context) {
      final d = _dataMap(context);
      final labelN = context.dataContext.subscribeToString(
        d['label'] as Map<String, Object?>?,
      );
      final valueN = context.dataContext.subscribeToString(
        d['value'] as Map<String, Object?>?,
      );
      final changeN = context.dataContext.subscribeToString(
        d['change'] as Map<String, Object?>?,
      );
      return ValueListenableBuilder<String?>(
        valueListenable: labelN,
        builder:
            (ctx, label, _) => ValueListenableBuilder<String?>(
              valueListenable: valueN,
              builder:
                  (ctx, value, _) => ValueListenableBuilder<String?>(
                    valueListenable: changeN,
                    builder:
                        (ctx, change, _) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                label ?? '',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    value ?? '',
                                    style: AppTextStyles.labelLarge.copyWith(
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (change != null) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      change,
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.accentGreen,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                  ),
            ),
      );
    },
  );

  // ── ActionSuggestion ──
  static final actionSuggestionItem = CatalogItem(
    name: 'ActionSuggestion',
    dataSchema: S.object(
      properties: {
        'action': S.string(description: 'Suggested action'),
        'reason': S.string(description: 'Why this action is recommended'),
        'priority': S.string(
          description: 'Priority level',
          enumValues: ['high', 'medium', 'low'],
        ),
      },
      required: ['action'],
    ),
    widgetBuilder: (context) {
      final d = _dataMap(context);
      final actionN = context.dataContext.subscribeToString(
        d['action'] as Map<String, Object?>?,
      );
      final reasonN = context.dataContext.subscribeToString(
        d['reason'] as Map<String, Object?>?,
      );
      final priorityN = context.dataContext.subscribeToString(
        d['priority'] as Map<String, Object?>?,
      );
      return ValueListenableBuilder<String?>(
        valueListenable: actionN,
        builder:
            (ctx, action, _) => ValueListenableBuilder<String?>(
              valueListenable: reasonN,
              builder:
                  (ctx, reason, _) => ValueListenableBuilder<String?>(
                    valueListenable: priorityN,
                    builder: (ctx, priority, _) {
                      final prColor = switch (priority) {
                        'high' => AppColors.error,
                        'low' => AppColors.accentGreen,
                        _ => AppColors.accentOrange,
                      };
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 48,
                              decoration: BoxDecoration(
                                color: prColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    action ?? '',
                                    style: AppTextStyles.labelLarge.copyWith(
                                      fontSize: 13,
                                    ),
                                  ),
                                  if (reason != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      reason,
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (priority != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: prColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  priority.toUpperCase(),
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: prColor,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
            ),
      );
    },
  );
}
