import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../core/routes/routes.dart';
import '../core/session/app_session.dart';
import '../models/login_response.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '我的',
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: SafeArea(
        child: ValueListenableBuilder<LoginResponse?>(
          valueListenable: AppSession.instance.currentUser,
          builder: (context, user, _) {
            final clinicName = user?.customerName.isNotEmpty == true
                ? user!.customerName
                : '某某口腔门诊部';
            final phoneDesc = (user?.phoneMask.isNotEmpty == true)
                ? '手机号： ${user!.phoneMask}'
                : '有显号按显示来电称呼，没有的话这里显示手机号';

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildProfileHeaderCard(clinicName, phoneDesc),
                        const SizedBox(height: 16),
                        _buildOrderSection(),
                        const SizedBox(height: 12),
                        _buildProfileList(),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Color(0xFF09AA43), width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      onPressed: () => _handleLogout(context),
                      child: const Text(
                        '退出登录',
                        style: TextStyle(
                          color: Color(0xFF09AA43),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        selectedItemColor: const Color(0xFF09AA43),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.home);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.apps), label: '分类'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: '购物车'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
        ],
      ),
    );
  }

  Widget _buildProfileHeaderCard(String clinicName, String phoneDesc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            clinicName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            phoneDesc,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '我的订单',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOrderItem(Icons.assignment_turned_in, '待审核'),
              _buildOrderItem(Icons.receipt_long, '已审核'),
              _buildOrderItem(Icons.local_shipping_outlined, '已出库'),
              _buildOrderItem(Icons.check_circle_outline, '待收货'),
              _buildOrderItem(Icons.chat_bubble_outline, '售后'),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildOrderItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFE9F6EE),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFF09AA43),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: const [
          ListTile(
            title: Text('我的账单'),
            trailing: Icon(Icons.chevron_right, color: Colors.grey),
          ),
          Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            title: Text('我的收藏'),
            trailing: Icon(Icons.chevron_right, color: Colors.grey),
          ),
          Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            title: Text('地址管理'),
            trailing: Icon(Icons.chevron_right, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await ApiClient().post('/user/logout');
    } catch (e) {
      // 忽略退出异常，仅做本地清理
      debugPrint('退出登录失败：$e');
    } finally {
      AppSession.instance.update(null);
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    }
  }
}


