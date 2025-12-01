import 'dart:developer';

import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../core/routes/routes.dart';
import '../core/session/app_session.dart';
import '../models/login_response.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) {
      return;
    }
    setState(() {
      _isSubmitting = true;
    });

    try {
      // 示例请求，真实项目中替换为实际接口
      final response = await ApiClient().post('/user/login', data: {
        'phone': _phoneController.text,
        'password': _passwordController.text,
        'deviceType': 'APP',
        'authType': 'pass',
      });

      if (!mounted) {
        return;
      }
      // code 是 200，正常登录
      AppSession.instance.update(LoginResponse.fromJson(response));
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('登录失败：$e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              _buildLogo(),
              const SizedBox(height: 48),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildPhoneField(),
                    const SizedBox(height: 16),
                    _buildPasswordField(),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF65C18C),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                        onPressed: _isSubmitting ? null : _handleLogin,
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : const Text(
                                '登录',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        '忘记密码',
                        style: TextStyle(
                          color: Color(0xFF45B073),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              _buildOtherLoginSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              letterSpacing: 1.5,
            ),
            children: [
              TextSpan(text: 'CC', style: TextStyle(color: Color(0xFF83C51D))),
              TextSpan(text: 'DENTAL'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '松佰牙科供应链系统TEst',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      decoration: _inputDecoration(
        hintText: '请输入手机号',
        prefix: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Text(
            '+86 | ',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        prefixIcon: const Icon(
          Icons.phone_iphone,
          color: Color(0xFF9FA4AF),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入手机号';
        }
        if (value.length < 11) {
          return '手机号格式不正确';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: _inputDecoration(
        hintText: '请输入登录密码',
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: Color(0xFF9FA4AF),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF9FA4AF),
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入登录密码';
        }
        if (value.length < 6) {
          return '密码至少6位';
        }
        return null;
      },
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    Widget? prefix,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF8F8F8),
      hintText: hintText,
      prefixIcon: prefixIcon,
      prefixIconConstraints:
          const BoxConstraints(minWidth: 48, minHeight: 48),
      suffixIcon: suffixIcon,
      prefix: prefix,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        borderSide: const BorderSide(color: Color(0xFFE0E3EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        borderSide: const BorderSide(color: Color(0xFFE0E3EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        borderSide: const BorderSide(color: Color(0xFF65C18C)),
      ),
    );
  }

  Widget _buildOtherLoginSection() {
    return Column(
      children: [
        Row(
          children: const [
            Expanded(child: Divider(color: Color(0xFFE0E3EB))),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '其他登录方式',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            Expanded(child: Divider(color: Color(0xFFE0E3EB))),
          ],
        ),
        const SizedBox(height: 24),
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFE9F6EE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mail_outline,
                color: Color(0xFF45B073),
                size: 32,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '短信登录',
              style: TextStyle(color: Color(0xFF45B073)),
            ),
          ],
        ),
      ],
    );
  }
}

