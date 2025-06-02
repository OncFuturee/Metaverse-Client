
class AppConfig {
  final String apiUrl;
  final String environment;

  AppConfig({required this.apiUrl, required this.environment});

  static Future<AppConfig> fromEnvironment() async {
    // 模拟从环境变量或配置文件加载
    return AppConfig(
      apiUrl: 'https://api.example.com',
      environment: 'production',
    );
  }
}