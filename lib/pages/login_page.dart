import 'dart:async';
import 'package:flutter/material.dart';
import 'package:babylove_flutter/services/auth_service.dart';
import 'package:babylove_flutter/services/storage_service.dart';
import 'package:babylove_flutter/core/network/network_exception.dart';
import 'main_page.dart';
import 'legal_document_page.dart';

/// 登录页面
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _codeFocusNode = FocusNode();
  final _authService = AuthService();

  bool _isAgreed = false;
  bool _isLoading = false;
  bool _canSendCode = true;
  int _countdown = 60;
  Timer? _timer;
  String? _receivedCode; // 接收到的验证码

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _codeFocusNode.dispose();
    _timer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  /// 发送验证码
  Future<void> _sendVerificationCode() async {
    if (!_canSendCode) return;

    // 验证手机号
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || !_isValidPhone(phone)) {
      _showSnackBar('请输入正确的手机号', Colors.red);
      return;
    }

    setState(() {
      _canSendCode = false;
      _countdown = 60;
    });

    // 启动倒计时
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _canSendCode = true;
          timer.cancel();
        }
      });
    });

    try {
      // 调用发送验证码的 API
      final response = await _authService.sendSmsCode(phone: phone);

      if (response.isSuccess) {
        // 开发环境会返回验证码
        if (response.data?.code != null) {
          setState(() {
            _receivedCode = response.data!.code;
          });
          _showSnackBar('验证码已发送: ${response.data!.code}', Colors.green);
          // 自动聚焦验证码输入框,弹出键盘
          _codeFocusNode.requestFocus();
        } else {
          _showSnackBar('验证码已发送', Colors.green);
          // 即使没有返回验证码也聚焦输入框
          _codeFocusNode.requestFocus();
        }
      } else {
        _showSnackBar('发送失败: ${response.message}', Colors.red);
        // 发送失败时重置倒计时
        _timer?.cancel();
        setState(() {
          _canSendCode = true;
        });
      }
    } catch (e) {
      _showSnackBar('发送失败: $e', Colors.red);
      // 发送失败时重置倒计时
      _timer?.cancel();
      setState(() {
        _canSendCode = true;
      });
    }
  }

  /// 验证手机号格式
  bool _isValidPhone(String phone) {
    return RegExp(r'^1[3-9]\d{9}$').hasMatch(phone);
  }

  /// 处理登录
  Future<void> _handleLogin() async {
    // 检查是否同意协议
    if (!_isAgreed) {
      _shakeController.forward(from: 0);
      _showSnackBar('请先同意用户协议和隐私政策', Colors.orange);
      return;
    }

    // 验证表单
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final phone = _phoneController.text.trim();
      final code = _codeController.text.trim();

      // 调用登录接口
      final response = await _authService.loginWithSms(
        phone: phone,
        code: code,
        nickname: '',
      );

      debugPrint('Login response: $response');
      if (response.isSuccess && response.data != null) {
        // 保存 token 到本地
        await StorageService().saveToken(response.data!.token);

        // 跳转到主页
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainPage()),
          );
        }
      } else {
        _showSnackBar('登录失败: ${response.message}', Colors.red);
      }
    } on NetworkException catch (e) {
      _showSnackBar('登录失败: ${e.message}', Colors.red);
    } catch (e) {
      _showSnackBar('登录失败: $e', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 显示提示信息
  void _showSnackBar(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 60),

                      // 应用图标和名称
                      _buildAppHeader(),

                      const SizedBox(height: 60),

                      // 手机号输入
                      _buildPhoneInput(),

                      const SizedBox(height: 20),

                      // 验证码输入
                      _buildCodeInput(),

                      const SizedBox(height: 30),

                      // 用户协议勾选
                      _buildAgreementCheckbox(),

                      const SizedBox(height: 30),

                      // 登录按钮
                      _buildLoginButton(),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            // 键盘上方的验证码工具栏
            if (_receivedCode != null && _codeFocusNode.hasFocus)
              _buildCodeToolbar(),
          ],
        ),
      ),
    );
  }

  /// 应用头部（图标和名称）
  Widget _buildAppHeader() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            'assets/images/app_icon.png',
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '幼安管家',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  /// 手机号输入框
  Widget _buildPhoneInput() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      maxLength: 11,
      decoration: InputDecoration(
        labelText: '手机号',
        hintText: '请输入手机号',
        prefixIcon: const Icon(Icons.phone_android),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        counterText: '',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入手机号';
        }
        if (!_isValidPhone(value)) {
          return '请输入正确的手机号';
        }
        return null;
      },
    );
  }

  /// 验证码输入框
  Widget _buildCodeInput() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _codeController,
            focusNode: _codeFocusNode,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              labelText: '验证码',
              hintText: '请输入验证码',
              prefixIcon: const Icon(Icons.message),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              counterText: '',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入验证码';
              }
              if (value.length < 4) {
                return '验证码长度不正确';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 120,
          height: 56,
          child: ElevatedButton(
            onPressed: _canSendCode ? _sendVerificationCode : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _canSendCode ? Colors.blue : Colors.grey,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey,
              disabledForegroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _canSendCode ? '获取验证码' : '${_countdown}s',
              style: const TextStyle(fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  /// 验证码工具栏(显示在键盘上方)
  Widget _buildCodeToolbar() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.vpn_key, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          const Text(
            '收到验证码:',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () {
                // 点击验证码自动填入
                _codeController.text = _receivedCode!;
                setState(() {
                  _receivedCode = null; // 填入后隐藏工具栏
                });
                _codeFocusNode.unfocus(); // 关闭键盘
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _receivedCode!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward,
                      size: 18,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.close, size: 22),
            onPressed: () {
              setState(() {
                _receivedCode = null;
              });
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            color: Colors.grey.shade600,
          ),
        ],
      ),
    );
  }

  /// 用户协议勾选框
  Widget _buildAgreementCheckbox() {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: Row(
        children: [
          Checkbox(
            value: _isAgreed,
            onChanged: (value) {
              setState(() {
                _isAgreed = value ?? false;
              });
            },
          ),
          Expanded(
            child: Wrap(
              children: [
                const Text('我已阅读并同意'),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LegalDocumentPage(
                          title: '用户协议',
                          url: '/legal/user-agreement.html',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    '《用户协议》',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const Text('和'),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LegalDocumentPage(
                          title: '隐私政策',
                          url: '/legal/privacy-policy.html',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    '《隐私政策》',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 登录按钮
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                '登录',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
