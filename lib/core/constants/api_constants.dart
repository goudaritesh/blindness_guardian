class ApiConstants {
  // Update this with your Render URL after deployment
  // For local testing: static const String baseUrl = 'http://10.0.2.2:5000'; // Android Emulator
  static const String baseUrl = 'http://192.168.1.100:5000'; // Replace with your laptop IP
  
  static const String signup = '$baseUrl/api/auth/signup';
  static const String login = '$baseUrl/api/auth/login';
  static const String iotLocation = '$baseUrl/api/iot/location';
  static const String iotAlert = '$baseUrl/api/iot/alert';
  static const String iotStatus = '$baseUrl/api/iot/status';
  static const String alerts = '$baseUrl/api/alerts';
}
