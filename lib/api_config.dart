class ApiConfig {

  static const bool isProduction = false;

  static String get baseUrl {

    if (isProduction) {

      return "https://meeting-app-gsa.onrender.com";

    }

    return "http://10.0.2.2:8000";
  }
}