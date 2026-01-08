import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:babylove_flutter/core/network/network_exception.dart';
import 'package:babylove_flutter/models/care_receiver_model.dart';
import 'package:babylove_flutter/pages/main_page.dart';
import 'package:babylove_flutter/services/app_state_service.dart';
import 'package:babylove_flutter/services/care_receiver_service.dart';

class CreateFamilyPage extends StatefulWidget {
  const CreateFamilyPage({super.key});

  @override
  State<CreateFamilyPage> createState() => _CreateFamilyPageState();
}

class _CreateFamilyPageState extends State<CreateFamilyPage> {
  final _formKey = GlobalKey<FormState>();

  // 家庭信息
  final _familyNameController = TextEditingController();
  final _myNicknameController = TextEditingController();
  String? _familyAvatarUrl; // 占位，未实现上传

  // 被照顾者信息
  final _careNicknameController = TextEditingController();
  String? _careGender; // 'male'/'female'
  DateTime? _careBirthDate;
  String? _careAvatarUrl; // 占位，未实现上传

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 出生日期默认选中今天
    _careBirthDate = DateTime.now();
  }

  @override
  void dispose() {
    _familyNameController.dispose();
    _myNicknameController.dispose();
    _careNicknameController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, Color color) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _showBirthDatePicker() async {
    final now = DateTime.now();
    DateTime tempDate = _careBirthDate ?? now;

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => Container(
        height: 300,
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            // 操作栏
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('取消'),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      setState(() => _careBirthDate = tempDate);
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('完成'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: tempDate,
                maximumDate: now,
                minimumDate: DateTime(1900, 1, 1),
                onDateTimeChanged: (d) => tempDate = d,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _genderLabel(String? value) {
    switch (value) {
      case 'male':
        return '男';
      case 'female':
        return '女';
      default:
        return '选择性别';
    }
  }

  Future<void> _showGenderActionSheet(ValueChanged<String?> onSelected) async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text('选择性别'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(ctx).pop();
              onSelected('male');
            },
            child: const Text('男'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(ctx).pop();
              onSelected('female');
            },
            child: const Text('女'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('取消'),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_careGender == null || _careGender!.isEmpty) {
      _showSnackBar('请选择被照顾者性别', Theme.of(context).colorScheme.error);
      return;
    }
    if (_careBirthDate == null) {
      _showSnackBar('请选择被照顾者出生年月', Theme.of(context).colorScheme.error);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final cr = CareReceiver(
        id: '',
        name: _careNicknameController.text.trim(),
        gender: _careGender,
        birthDate: _careBirthDate!.millisecondsSinceEpoch ~/ 1000,
        avatar: _careAvatarUrl,
      );

      final svc = CareReceiverService();
      final resp = await svc.createFamilyWithCareReceiver(
        familyName: _familyNameController.text.trim(),
        familyAvatar: _familyAvatarUrl,
        myNickname: _myNicknameController.text.trim(),
        careReceiver: cr,
      );

      if (resp.isSuccess && resp.data != null) {
        AppStateService().setLastFamily(resp.data!.family);
        AppStateService().setLastCareReceiver(resp.data!.careReceiver);
        if (!mounted) return;
        _showSnackBar('创建家庭成功', Theme.of(context).colorScheme.primary);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainPage()),
          (route) => false,
        );
      } else {
        _showSnackBar('创建失败: ${resp.message}', Theme.of(context).colorScheme.error);
      }
    } on NetworkException catch (e) {
      _showSnackBar('创建失败: ${e.message}', Theme.of(context).colorScheme.error);
    } catch (e) {
      _showSnackBar('创建失败: $e', Theme.of(context).colorScheme.error);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildAvatarPlaceholder({required VoidCallback onTap}) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(color: scheme.surfaceVariant, shape: BoxShape.circle),
        child: Icon(Icons.add_photo_alternate, size: 28, color: scheme.onSurfaceVariant),
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(child: Divider(color: Theme.of(context).dividerTheme.color, thickness: 1, endIndent: 12)),
        Text(text, style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant)),
        Expanded(child: Divider(color: Theme.of(context).dividerTheme.color, thickness: 1, indent: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('创建家庭'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 家庭信息
              const SizedBox(height: 4),
              _buildSectionHeader('家庭信息'),
              const SizedBox(height: 16),
              // 头像 + 家庭名称（同一行）
              Row(
                children: [
                  _buildAvatarPlaceholder(
                    onTap: () => _showSnackBar('家庭头像上传功能开发中', Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _familyNameController,
                      decoration: InputDecoration(
                        labelText: '家庭名称',
                        hintText: '请输入家庭名称',
                        prefixIcon: const Icon(Icons.home),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? '请输入家庭名称' : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 我在家庭中的昵称
              TextFormField(
                controller: _myNicknameController,
                decoration: InputDecoration(
                  labelText: '我在家庭中的昵称',
                  hintText: '请输入您的昵称',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? '请输入您的昵称' : null,
              ),

              const SizedBox(height: 30),

              // 分割线
              _buildSectionHeader('被照顾者信息'),
              const SizedBox(height: 20),

              // 头像 + 昵称（同一行）
              Row(
                children: [
                  _buildAvatarPlaceholder(
                    onTap: () => _showSnackBar('被照顾者头像上传功能开发中', Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _careNicknameController,
                      decoration: InputDecoration(
                        labelText: '被照顾者昵称',
                        hintText: '请输入昵称',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? '请输入昵称' : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 性别（Action Sheet 选择）
              FormField<String>(
                validator: (_) => (_careGender == null || _careGender!.isEmpty) ? '请选择性别' : null,
                builder: (state) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => _showGenderActionSheet((val) {
                        setState(() => _careGender = val);
                        state.didChange(val);
                      }),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: '性别',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          _genderLabel(_careGender),
                          style: TextStyle(
                            fontSize: 16,
                            color: _careGender == null
                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    if (state.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          state.errorText!,
                          style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 出生年月日
              InkWell(
                onTap: _showBirthDatePicker,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: '出生年月日',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _careBirthDate == null
                        ? '选择出生年月日'
                        : '${_careBirthDate!.year}-${_careBirthDate!.month.toString().padLeft(2, '0')}-${_careBirthDate!.day.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 16,
                      color: _careBirthDate == null
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('创建'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
