import 'package:flutter/material.dart';

import '../../pages/home_page.dart';
import '../../pages/login_page.dart';

/// 路由名称常量
class AppRoutes {
  // 私有构造函数，防止实例化
  AppRoutes._();

  /// 登录页
  static const String login = '/login';

  /// 首页
  static const String home = '/home';
}

/// 路由生成器
class RouteGenerator {
  /// 生成路由
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case AppRoutes.login:
        return _buildRoute(
          const LoginPage(),
          settings: settings,
        );

      case AppRoutes.home:
        return _buildRoute(
          const HomePage(),
          settings: settings,
        );

      default:
        return _buildRoute(
          _buildNotFoundPage(settings.name),
          settings: settings,
        );
    }
  }

  /// 构建路由页面
  static MaterialPageRoute _buildRoute(
    Widget page, {
    required RouteSettings settings,
  }) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }

  /// 构建404页面
  static Widget _buildNotFoundPage(String? routeName) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('页面未找到'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              '路由 "$routeName" 未找到',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


