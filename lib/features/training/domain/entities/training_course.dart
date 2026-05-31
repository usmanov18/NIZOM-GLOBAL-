import 'package:equatable/equatable.dart';

class TrainingCourse extends Equatable {
  final String id;
  final String title;
  final String description;
  final String category;
  final Duration duration;
  final int lessons;
  final double progress;
  final TrainingCourseStatus status;

  const TrainingCourse({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.duration,
    required this.lessons,
    required this.progress,
    required this.status,
  });

  bool get isCompleted => status == TrainingCourseStatus.completed;
  bool get isInProgress => status == TrainingCourseStatus.inProgress;
  bool get hasCertificate => isCompleted;

  TrainingCourse copyWith({
    double? progress,
    TrainingCourseStatus? status,
  }) {
    return TrainingCourse(
      id: id,
      title: title,
      description: description,
      category: category,
      duration: duration,
      lessons: lessons,
      progress: progress ?? this.progress,
      status: status ?? this.status,
    );
  }

  factory TrainingCourse.fromJson(Map<String, dynamic> json) {
    final progress = (json['progress'] ?? 0).toDouble().clamp(0.0, 1.0);
    return TrainingCourse(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      duration: Duration(minutes: json['duration_minutes'] ?? 0),
      lessons: json['lessons'] ?? 0,
      progress: progress,
      status: TrainingCourseStatus.values.firstWhere(
        (item) => item.name == json['status'],
        orElse: () => progress >= 1
            ? TrainingCourseStatus.completed
            : progress > 0
                ? TrainingCourseStatus.inProgress
                : TrainingCourseStatus.notStarted,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'duration_minutes': duration.inMinutes,
        'lessons': lessons,
        'progress': progress,
        'status': status.name,
      };

  @override
  List<Object?> get props => [id, progress, status];
}

enum TrainingCourseStatus { notStarted, inProgress, completed }
