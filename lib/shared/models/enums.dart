/// All enums used across the Performance OS application.

enum TaskDomain {
  work,
  learning,
  health,
  personal;

  String get label {
    switch (this) {
      case TaskDomain.work:
        return 'Work';
      case TaskDomain.learning:
        return 'Learning';
      case TaskDomain.health:
        return 'Health';
      case TaskDomain.personal:
        return 'Personal';
    }
  }

  String get icon {
    switch (this) {
      case TaskDomain.work:
        return 'work';
      case TaskDomain.learning:
        return 'school';
      case TaskDomain.health:
        return 'fitness_center';
      case TaskDomain.personal:
        return 'favorite';
    }
  }
}

enum TaskUrgency {
  low,
  medium,
  high;

  String get label {
    switch (this) {
      case TaskUrgency.low:
        return 'Low';
      case TaskUrgency.medium:
        return 'Med';
      case TaskUrgency.high:
        return 'High';
    }
  }
}

enum EnergyLevel {
  low,
  medium,
  high;

  String get label {
    switch (this) {
      case EnergyLevel.low:
        return 'Low';
      case EnergyLevel.medium:
        return 'Med';
      case EnergyLevel.high:
        return 'High';
    }
  }

  String get icon {
    switch (this) {
      case EnergyLevel.low:
        return 'battery_low';
      case EnergyLevel.medium:
        return 'battery_5_bar';
      case EnergyLevel.high:
        return 'battery_full';
    }
  }
}

enum LayoutMode { focus, recovery, balanced }

enum OutcomeType {
  revenueGeneration,
  skillAcquisition,
  systemImprovement,
  strategicRelaxation;

  String get label {
    switch (this) {
      case OutcomeType.revenueGeneration:
        return 'Revenue Generation';
      case OutcomeType.skillAcquisition:
        return 'Skill Acquisition';
      case OutcomeType.systemImprovement:
        return 'System Improvement';
      case OutcomeType.strategicRelaxation:
        return 'Strategic Relaxation';
    }
  }
}

enum MoodType {
  focused,
  highEnergy,
  calm,
  tired;

  String get label {
    switch (this) {
      case MoodType.focused:
        return 'Focused';
      case MoodType.highEnergy:
        return 'High Energy';
      case MoodType.calm:
        return 'Calm';
      case MoodType.tired:
        return 'Tired';
    }
  }

  String get icon {
    switch (this) {
      case MoodType.focused:
        return 'sentiment_very_satisfied';
      case MoodType.highEnergy:
        return 'bolt';
      case MoodType.calm:
        return 'sentiment_neutral';
      case MoodType.tired:
        return 'battery_low';
    }
  }
}

enum TaskStatus {
  todo,
  ongoing,
  completed,
  blocked;

  String get label {
    switch (this) {
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.ongoing:
        return 'Ongoing';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.blocked:
        return 'Blocked';
    }
  }
}
