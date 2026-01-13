import 'package:flutter/material.dart';
import 'package:babylove_flutter/services/family_service.dart';
import 'package:babylove_flutter/services/app_state_service.dart';
import 'package:babylove_flutter/core/network/network_exception.dart';

/// 通用的加入家庭对话框
Future<bool> showJoinFamilyDialog(BuildContext context) async {
  final _familyService = FamilyService();
  final formKey = GlobalKey<FormState>();
  final nicknameController = TextEditingController();
  final inviteCodeController = TextEditingController();
  bool isLoading = false;

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: const Text('加入家庭'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 昵称
                TextFormField(
                  controller: nicknameController,
                  decoration: InputDecoration(
                    labelText: '我在家庭中的昵称',
                    hintText: '请输入您的昵称',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入您的昵称';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 邀请码
                TextFormField(
                  controller: inviteCodeController,
                  decoration: InputDecoration(
                    labelText: '邀请码',
                    hintText: '请输入邀请码',
                    prefixIcon: const Icon(Icons.qr_code),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入邀请码';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
            actions: [
            SizedBox(
              width: 90,
              height: 40,
              child: OutlinedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.of(context).pop(false);
                        },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('取消', style: TextStyle(fontSize: 16)),
              ),
            ),
            SizedBox(
              width: 90,
              height: 40,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (formKey.currentState!.validate()) {
                          setDialogState(() {
                            isLoading = true;
                          });

                          try {
                            final response = await _familyService.joinFamily(
                              inviteCode: inviteCodeController.text.trim(),
                              nickname: nicknameController.text.trim(),
                            );

                            if (response.isSuccess && response.data != null) {
                              // 保存家庭到全局状态
                              AppStateService().setLastFamily(
                                response.data!.family,
                              );

                              if (Navigator.of(context).mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('加入家庭成功'), backgroundColor: Colors.green),
                                );
                                Navigator.of(context).pop(true);
                              }
                            } else {
                              if (Navigator.of(context).mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('加入失败: ${response.message}'), backgroundColor: Colors.red),
                                );
                              }
                            }
                          } on NetworkException catch (e) {
                            if (Navigator.of(context).mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('加入失败: ${e.message}'), backgroundColor: Colors.red),
                              );
                            }
                          } catch (e) {
                            if (Navigator.of(context).mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('加入失败: $e'), backgroundColor: Colors.red),
                              );
                            }
                          } finally {
                            if (Navigator.of(context).mounted) {
                              setDialogState(() {
                                isLoading = false;
                              });
                            }
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('加入', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        );
      },
    ),
  );

  return result ?? false;
}
