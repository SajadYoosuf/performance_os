import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/tasks/domain/entities/task_entity.dart';
import 'package:app/features/tasks/presentation/providers/task_provider.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_text_styles.dart';
import 'package:app/shared/models/enums.dart';
import 'package:intl/intl.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskEntity task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TaskDomain _domain;
  late TaskUrgency _urgency;
  late EnergyLevel _energy;
  late DateTime? _startDate;
  late DateTime? _dueDate;
  late TaskStatus _status;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(
      text: widget.task.description ?? '',
    );
    _domain = widget.task.domain;
    _urgency = widget.task.urgency;
    _energy = widget.task.energyRequired;
    _startDate = widget.task.startDate;
    _dueDate = widget.task.dueDate;
    _status = widget.task.status;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = (isStart ? _startDate : _dueDate) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _dueDate = picked;
        }
      });
    }
  }

  void _saveChanges() {
    final updatedTask = widget.task.copyWith(
      title: _titleController.text,
      description: _descriptionController.text,
      domain: _domain,
      urgency: _urgency,
      energyRequired: _energy,
      startDate: _startDate,
      dueDate: _dueDate,
      status: _status,
      isCompleted: _status == TaskStatus.completed,
      completedAt: _status == TaskStatus.completed ? DateTime.now() : null,
    );
    context.read<TaskProvider>().updateTask(updatedTask);
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Task updated successfully')));
  }

  void _deleteTask() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Task'),
            content: const Text('Are you sure you want to delete this task?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      if (!mounted) return;
      context.read<TaskProvider>().deleteTask(widget.task.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Task' : 'Task Details',
          style: AppTextStyles.heading4,
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _deleteTask,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField(
              'TITLE',
              TextField(
                controller: _titleController,
                enabled: _isEditing,
                style: AppTextStyles.heading3,
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
            const SizedBox(height: 24),
            _buildField(
              'DESCRIPTION',
              TextField(
                controller: _descriptionController,
                enabled: _isEditing,
                maxLines: 3,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Add details...',
                  border:
                      _isEditing
                          ? const OutlineInputBorder()
                          : InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildDropdownField(
                    'DOMAIN',
                    TaskDomain.values,
                    _domain,
                    (v) => setState(() => _domain = v!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdownField(
                    'URGENCY',
                    TaskUrgency.values,
                    _urgency,
                    (v) => setState(() => _urgency = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDropdownField(
              'STATUS',
              TaskStatus.values,
              _status,
              (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 24),
            _buildField(
              'START DATE',
              _buildDatePicker(_startDate, () => _selectDate(context, true)),
            ),
            const SizedBox(height: 24),
            _buildField(
              'DUE DATE',
              _buildDatePicker(_dueDate, () => _selectDate(context, false)),
            ),
            const SizedBox(height: 40),
            if (_isEditing)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textTertiary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildDropdownField<T extends Enum>(
    String label,
    List<T> values,
    T current,
    ValueChanged<T?> onChanged,
  ) {
    return _buildField(
      label,
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: current,
            isExpanded: true,
            onChanged: _isEditing ? onChanged : null,
            items:
                values
                    .map(
                      (v) => DropdownMenuItem(
                        value: v,
                        child: Text(v.toString().split('.').last),
                      ),
                    )
                    .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(DateTime? date, VoidCallback onTap) {
    final dateStr =
        date != null ? DateFormat('MMM d, yyyy').format(date) : 'Not set';
    return InkWell(
      onTap: _isEditing ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(dateStr, style: AppTextStyles.bodyMedium),
            Icon(Icons.calendar_today, size: 18, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
