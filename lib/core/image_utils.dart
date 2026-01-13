import 'package:flutter/material.dart';

class AppImageUtils {
  AppImageUtils._();

  static const String _resourcePrefix = 'resource://';

  static bool isResource(String? value) {
    return value != null && value.startsWith(_resourcePrefix);
    }

  static bool isNetwork(String? value) {
    if (value == null) return false;
    return value.startsWith('http://') || value.startsWith('https://');
  }

  /// Convert a resource path like `resource:///family/family0.png`
  /// to a Flutter asset key like `assets/images/family/family0.png`.
  static String? resourceToAssetKey(String? resourcePath) {
    if (!isResource(resourcePath)) return null;
    var rest = resourcePath!.substring(_resourcePrefix.length);
    while (rest.startsWith('/')) {
      rest = rest.substring(1);
    }
    return 'assets/images/$rest';
  }

  /// Build an ImageProvider from avatar string according to rules:
  /// 1) resource:/// -> AssetImage(assets/images/...)
  /// 2) http(s)://  -> NetworkImage
  /// 3) others      -> use defaultResource if provided (resource:// only), else null
  static ImageProvider<Object>? imageProviderFor(
    String? avatar, {
    String? defaultResource,
  }) {
    if (isResource(avatar)) {
      final key = resourceToAssetKey(avatar);
      if (key != null) return AssetImage(key);
    } else if (isNetwork(avatar)) {
      return NetworkImage(avatar!);
    }

    if (defaultResource != null && isResource(defaultResource)) {
      final key = resourceToAssetKey(defaultResource);
      if (key != null) return AssetImage(key);
    }

    return null;
  }
}
