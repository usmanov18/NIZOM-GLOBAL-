import 'package:equatable/equatable.dart';

// ============================================================
// ATTENDANCE ENTITIES - Davomat va ish jadvali
// ============================================================

/// Davomat holati
enum AttendanceStatus {
  present, // Kelgan
  absent, // Kelmagan
  late, // Kechikkan
  halfDay, // Yarim kun
  onLeave, // Ta'tilda
  holiday, // Bayram
}

/// Ish jadvali
class WorkSchedule extends Equatable {
  factory WorkSchedule.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String id;
  final String name;
  final String startTime; // 08:00
  final String endTime; // 18:00
  final List<String> workDays;
  final int breakMinutes; // 60
  final bool isActive;

  const WorkSchedule({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.workDays,
    required this.breakMinutes,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id];
}

/// Davomat yozuvi
class AttendanceRecord extends Equatable {
  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String id;
  final String employeeId;
  final String employeeName;
  final DateTime date;
  final String? checkInTime;
  final String? checkOutTime;
  final double? checkInLatitude;
  final double? checkInLongitude;
  final double? checkOutLatitude;
  final double? checkOutLongitude;
  final AttendanceStatus status;
  final Duration? workDuration;
  final Duration? lateDuration;
  final String? notes;

  const AttendanceRecord({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkOutLatitude,
    this.checkOutLongitude,
    required this.status,
    this.workDuration,
    this.lateDuration,
    this.notes,
  });

  bool get isCheckedIn => checkInTime != null;
  bool get isCheckedOut => checkOutTime != null;
  bool get isLate => status == AttendanceStatus.late;

  @override
  List<Object?> get props => [id, employeeId, date];
}

/// Ta'til so'rovi
class LeaveRequest extends Equatable {
  factory LeaveRequest.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String id;
  final String employeeId;
  final String employeeName;
  final String type; // annual, sick, personal, unpaid
  final DateTime startDate;
  final DateTime endDate;
  final int days;
  final String reason;
  final String status; // pending, approved, rejected
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? rejectionReason;

  const LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.reason,
    required this.status,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
  });

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  @override
  List<Object?> get props => [id, status];
}

/// Ish haqi hisoblash
class SalaryCalculation extends Equatable {
  factory SalaryCalculation.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();
  final String employeeId;
  final String month;
  final double baseSalary;
  final int workDays;
  final int actualDays;
  final int lateDays;
  final int absentDays;
  final int leaveDays;
  final double overtimeHours;
  final double overtimePay;
  final double deductions;
  final double bonus;
  final double netSalary;

  const SalaryCalculation({
    required this.employeeId,
    required this.month,
    required this.baseSalary,
    required this.workDays,
    required this.actualDays,
    required this.lateDays,
    required this.absentDays,
    required this.leaveDays,
    required this.overtimeHours,
    required this.overtimePay,
    required this.deductions,
    required this.bonus,
    required this.netSalary,
  });

  @override
  List<Object?> get props => [employeeId, month];
}
