import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_text_styles.dart';
import 'package:app/shared/models/enums.dart';
import 'package:app/shared/widgets/glass_card.dart';
import 'package:app/features/tasks/domain/entities/task_entity.dart';
import 'package:app/features/tasks/presentation/providers/task_provider.dart';
import 'package:app/features/tasks/presentation/screens/add_task_screen.dart';
import 'package:app/features/tasks/presentation/screens/task_detail_screen.dart';

/// Task list screen with day/week/month tabs & domain category filters.
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});
  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  TaskDomain? _selectedDomain;
  bool _showCompleted = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<TaskEntity> _getFilteredTasks(TaskProvider tp) {
    List<TaskEntity> tasks;
    if (_showCompleted) {
      tasks = switch (_tabController.index) {
        0 => tp.completedToday,
        1 => tp.completedThisWeek,
        2 => tp.completedThisMonth,
        _ => tp.completedToday,
      };
    } else {
      tasks = switch (_tabController.index) {
        0 => tp.todayTasks,
        1 => tp.thisWeekTasks,
        2 => tp.thisMonthTasks,
        _ => tp.todayTasks,
      };
    }
    // Apply domain filter.
    if (_selectedDomain != null) {
      tasks = tasks.where((t) => t.domain == _selectedDomain).toList();
    }
    return tasks;
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final tp = context.watch<TaskProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, primary, tp),
            _buildTabBar(primary),
            _buildDomainChips(primary),
            _buildToggleRow(primary),
            Expanded(child: _buildTaskList(context, primary, tp)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const AddTaskScreen())),
        backgroundColor: primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color primary, TaskProvider tp) {
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary, AppColors.accentGreen],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.task_alt, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Tasks',
                  style: AppTextStyles.heading3.copyWith(fontSize: 18),
                ),
                Text(
                  DateFormat('EEEE, MMM d').format(now),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Stats badge
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            borderRadius: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppColors.accentGreen,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${tp.completedToday.length}',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.accentGreen,
                    fontSize: 13,
                  ),
                ),
                Text(
                  ' today',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(Color primary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: AppTextStyles.labelLarge.copyWith(fontSize: 12),
          unselectedLabelStyle: AppTextStyles.bodySmall,
          dividerHeight: 0,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'This Week'),
            Tab(text: 'This Month'),
          ],
        ),
      ),
    );
  }

  Widget _buildDomainChips(Color primary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _DomainChip(
              label: 'All',
              isSelected: _selectedDomain == null,
              color: primary,
              onTap: () => setState(() => _selectedDomain = null),
            ),
            const SizedBox(width: 8),
            ...TaskDomain.values.map(
              (d) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _DomainChip(
                  label: d.label,
                  isSelected: _selectedDomain == d,
                  color: _domainColor(d),
                  onTap: () => setState(() => _selectedDomain = d),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow(Color primary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
      child: Row(
        children: [
          Text(
            _showCompleted ? 'COMPLETED' : 'PENDING',
            style: AppTextStyles.sectionHeader.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() => _showCompleted = !_showCompleted),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _showCompleted ? Icons.pending_actions : Icons.check_circle,
                    size: 14,
                    color: primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _showCompleted ? 'Show Pending' : 'Show Completed',
                    style: AppTextStyles.caption.copyWith(
                      color: primary,
                      fontWeight: FontWeight.w700,
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

  Widget _buildTaskList(BuildContext context, Color primary, TaskProvider tp) {
    final tasks = _getFilteredTasks(tp);

    if (tp.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tasks.isEmpty) {
      return _buildEmptyState(primary);
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _TaskCard(
          task: task,
          onComplete: () => tp.completeTask(task),
          onDelete: () => tp.deleteTask(task.id),
        );
      },
    );
  }

  Widget _buildEmptyState(Color primary) {
    final label = switch (_tabController.index) {
      0 => 'today',
      1 => 'this week',
      2 => 'this month',
      _ => 'today',
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _showCompleted ? Icons.emoji_events : Icons.inbox_outlined,
                color: primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _showCompleted
                  ? 'No completed tasks $label'
                  : 'No pending tasks $label',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _showCompleted
                  ? 'Complete some tasks to see them here!'
                  : 'Tap + to add your first task',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _domainColor(TaskDomain d) => switch (d) {
    TaskDomain.work => AppColors.accentBlue,
    TaskDomain.learning => AppColors.accentOrange,
    TaskDomain.health => AppColors.accentGreen,
    TaskDomain.personal => AppColors.primaryMobile,
  };
}

// ── Domain filter chip ──

class _DomainChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _DomainChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.2),
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            color: isSelected ? Colors.white : color,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

// ── Task card with swipe actions ──

class _TaskCard extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.task,
    required this.onComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final domainColor = switch (task.domain) {
      TaskDomain.work => AppColors.accentBlue,
      TaskDomain.learning => AppColors.accentOrange,
      TaskDomain.health => AppColors.accentGreen,
      TaskDomain.personal => AppColors.primaryMobile,
    };

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
        );
      },
      child: Dismissible(
        key: ValueKey(task.id),
        direction:
            task.isCompleted
                ? DismissDirection.endToStart
                : DismissDirection.horizontal,
        background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 24),
          decoration: BoxDecoration(
            color: AppColors.accentGreen,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.check, color: Colors.white),
        ),
        secondaryBackground: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_outline, color: Colors.white),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            onComplete();
            return false;
          }
          return true;
        },
        onDismissed: (_) => onDelete(),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Domain color bar
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: domainColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 14),
              // Status circle
              GestureDetector(
                onTap: task.isCompleted ? null : onComplete,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color:
                        task.isCompleted
                            ? AppColors.accentGreen
                            : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          task.isCompleted
                              ? AppColors.accentGreen
                              : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child:
                      task.isCompleted
                          ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                          : null,
                ),
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontSize: 13,
                        decoration:
                            task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                        color:
                            task.isCompleted
                                ? AppColors.textTertiary
                                : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _InfoChip(
                          icon: Icons.flag,
                          label: task.domain.label,
                          color: domainColor,
                        ),
                        const SizedBox(width: 6),
                        _InfoChip(
                          icon: Icons.bolt,
                          label: '${task.impactScore.toInt()}/10',
                          color:
                              task.isHighImpact
                                  ? AppColors.accentOrange
                                  : AppColors.textTertiary,
                        ),
                        const SizedBox(width: 6),
                        _InfoChip(
                          icon: Icons.timer,
                          label: '${task.estimatedMinutes}m',
                          color: AppColors.textTertiary,
                        ),
                        if (task.isOverdue) ...[
                          const SizedBox(width: 6),
                          _InfoChip(
                            icon: Icons.warning_amber,
                            label: 'Overdue',
                            color: AppColors.error,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Due date badge
              if (task.dueDate != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        task.isOverdue
                            ? AppColors.errorLight
                            : primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    DateFormat('MMM d').format(task.dueDate!),
                    style: AppTextStyles.caption.copyWith(
                      color: task.isOverdue ? AppColors.error : primary,
                      fontWeight: FontWeight.w700,
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 2),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}
