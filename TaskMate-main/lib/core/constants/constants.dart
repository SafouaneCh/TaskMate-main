class Constants {
  static String backendUri = "http://192.168.1.2:8000";
}

// API Endpoints
class ApiEndpoints {
  static String get health => '${Constants.backendUri}/health';
  static String get aiTest => '${Constants.backendUri}/tasks/ai/test';
  static String get aiCreate => '${Constants.backendUri}/tasks/ai';
  static String get auth => '${Constants.backendUri}/auth';
  static String get tasks => '${Constants.backendUri}/tasks';
}
