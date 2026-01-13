import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

/// 显示本地 assets 图片的选择器（基于 AssetManifest.json 枚举）
/// - subdir: 子目录，例如 'family' 或 'dependent'
/// 返回选择后的 resource 路径（例如：resource:///family/family0.png）
Future<String?> showAssetImagePicker(
  BuildContext context, {
  required String subdir,
  String? title,
  String? initialSelectedResource,
}) async {
  Map<String, dynamic>? manifestMap;
  List<String> assets;
  try {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    manifestMap = json.decode(manifestContent) as Map<String, dynamic>;
  } catch (_) {
    manifestMap = null;
  }

  final cleaned = subdir
      .replaceAll(RegExp(r'^/+'), '')
      .replaceAll(RegExp(r'/+$'), '');
  final prefix = 'assets/images/$cleaned/';

  if (manifestMap != null) {
    assets = manifestMap.keys
        .where((key) => key.startsWith(prefix))
        .toList()
      ..sort();
  } else {
    // Fallback: use known assets when manifest is unavailable
    if (cleaned == 'family') {
      assets = List<String>.generate(10, (i) => 'assets/images/family/family$i.png');
    } else if (cleaned == 'dependent') {
      assets = [
        'assets/images/dependent/default.png',
        'assets/images/dependent/boy0.png',
        'assets/images/dependent/boy1.png',
        'assets/images/dependent/girl0.png',
        'assets/images/dependent/girl1.png',
      ];
    } else {
      assets = const [];
    }
  }

  return showDialog<String>(
    context: context,
    builder: (ctx) {
      String? selectedResource = initialSelectedResource;

      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            insetPadding: const EdgeInsets.all(16),
            child: SizedBox(
              width: 360,
              height: 480,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(title ?? '选择图片', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: assets.isEmpty
                        ? const Center(child: Text('未找到资源图片'))
                        : GridView.builder(
                            padding: const EdgeInsets.all(12),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                            ),
                            itemCount: assets.length,
                            itemBuilder: (context, index) {
                              final assetPath = assets[index];
                              final parts = assetPath.split('/');
                              final fileName = parts.isNotEmpty ? parts.last : '';
                              final resource = 'resource:///$cleaned/$fileName';
                              final isSelected = selectedResource != null && selectedResource == resource;
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedResource = resource;
                                  });
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 180),
                                        curve: Curves.easeInOut,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: isSelected
                                                ? Theme.of(context).colorScheme.primary
                                                : Colors.transparent,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                                    blurRadius: 10,
                                                    spreadRadius: 1,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(6),
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              Image.asset(assetPath, fit: BoxFit.cover),
                                              if (isSelected)
                                                Container(
                                                  color: Colors.black.withOpacity(0.08),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        Positioned(
                                          top: 6,
                                          right: 6,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).colorScheme.primary,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.15),
                                                  blurRadius: 6,
                                                ),
                                              ],
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            child: const Icon(Icons.check, color: Colors.white, size: 16),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('取消'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: selectedResource == null
                              ? null
                              : () => Navigator.of(context).pop(selectedResource),
                          child: const Text('确定'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
