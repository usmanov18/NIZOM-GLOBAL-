import 'package:equatable/equatable.dart';

enum ConflictType { remoteNewer, localNewer, deletedOnServer, dataMismatch }

class DataConflict extends Equatable {
  final String entityId;
  final String entityType;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> serverData;
  final ConflictType type;
  final DateTime detectedAt;

  const DataConflict({
    required this.entityId,
    required this.entityType,
    required this.localData,
    required this.serverData,
    required this.type,
    required this.detectedAt,
  });

  @override
  List<Object?> get props => [entityId, entityType, type];
}
