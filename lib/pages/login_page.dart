import 'dart:async';
import 'package:flutter/material.dart';
import 'package:babylove_flutter/services/auth_service.dart';
import 'package:babylove_flutter/services/storage_service.dart';
import 'package:babylove_flutter/services/app_state_service.dart';
import 'package:babylove_flutter/core/network/network_exception.dart';
import 'package:babylove_flutter/core/utils.dart';
import 'legal_document_page.dart';
import 'welcome_page.dart';
import 'data_loading_page.dart';

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
      _showSnackBar('请输入正确的手机号', Theme.of(context).colorScheme.error);
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
          // 自动聚焦验证码输入框,弹出键盘
          _codeFocusNode.requestFocus();
        } else {
          _showSnackBar('验证码已发送', Theme.of(context).colorScheme.primary);
          // 即使没有返回验证码也聚焦输入框
          _codeFocusNode.requestFocus();
        }
      } else {
        _showErrorDialog('验证码发送失败: ${response.message ?? '未知错误'}');
        // 发送失败时重置倒计时
        _timer?.cancel();
        setState(() {
          _canSendCode = true;
        });
      }
    } catch (e) {
      final msg = '验证码发送失败: $e';
      _showErrorDialog(msg);
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
      _showSnackBar('请先同意用户协议和隐私政策', Theme.of(context).colorScheme.error);
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
        await StorageService().saveAccessToken(response.data!.accessToken);
        await StorageService().saveRefreshToken(response.data!.refreshToken);

        // 保存用户数据到全局状态
        final appState = AppStateService();
        appState.updateMeData(
          user: response.data!.user,
          lastFamily: response.data!.lastFamily,
          lastCareReceiver: response.data!.lastCareReceiver,
        );

        // 根据是否有家庭和护理对象决定跳转页面
        if (mounted) {
          if (appState.hasCompletedSetup) {
            // 已有家庭和护理对象，跳转到数据加载页，由其统一拉取数据并进入主页
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const DataLoadingPage()),
            );
          } else {
            // 没有家庭或护理对象，跳转到欢迎页
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const WelcomePage()),
            );
          }
        }
      } else {
        _showErrorDialog('登录失败: ${response.message ?? '未知错误'}');
      }
    } on NetworkException catch (e) {
      final msg = '登录失败: ${e.message}';
      _showErrorDialog(msg);
    } catch (e) {
      final msg = '登录失败: $e';
      _showErrorDialog(msg);
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

  void _showErrorDialog(String message) {
    AppUtils.showErrorDialog(
      context,
      title: '错误',
      message: message,
      okText: '确定',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        Text(
          '幼安管家',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
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
          child: OutlinedButton(
            onPressed: _canSendCode ? _sendVerificationCode : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: _canSendCode
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
              side: BorderSide(
                color: _canSendCode
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
                width: 1.5,
              ),
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
        color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
        border: Border(
          top: BorderSide(
            color:
                Theme.of(context).dividerTheme.color ??
                Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            Icons.vpn_key,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            '收到验证码:',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
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
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _receivedCode!,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      size: 18,
                      color: Theme.of(context).colorScheme.onPrimary,
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
            color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                  child: Text(
                    '《用户协议》',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
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
                  child: Text(
                    '《隐私政策》',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
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
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text(
                '登录',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
