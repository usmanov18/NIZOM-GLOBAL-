enum RequestPriority { high, medium, low }

class PriorityRequest {
  final RequestPriority priority;
  final Function action;

  PriorityRequest({required this.priority, required this.action});
}
