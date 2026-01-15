/// 通用工具类
/// 提供应用中常用的辅助方法
class AppUtils {
  AppUtils._();

  /// 将性别字符串转换为中文文本
  ///
  /// 参数：
  /// - [gender] 性别字符串 ('male', 'female', 'unknown' 等)
  ///
  /// 返回：中文性别文本 ('男', '女', '未知')
  static String getGenderText(String? gender) {
    switch (gender) {
      case 'male':
        return '男';
      case 'female':
        return '女';
      default:
        return '未知';
    }
  }

  /// 将性别整数转换为中文文本（用于 User 模型）
  ///
  /// 参数：
  /// - [gender] 性别整数 (0: 未知, 1: 男, 2: 女)
  ///
  /// 返回：中文性别文本 ('男', '女', '未知')
  static String getGenderTextFromInt(int? gender) {
    switch (gender) {
      case 1:
        return '男';
      case 2:
        return '女';
      default:
        return '未知';
    }
  }

  /// 将中文性别文本（例如 '男', '女'）转换为后端/模型使用的整数表示
  /// 返回：1 表示男，2 表示女，解析失败返回 null
  static int getGenderIntFromText(String? text) {
    if (text == null) return 0;
    switch (text.trim()) {
        case '男':
        case 'male':
        case 'm':
          return 1;
        case '女':
        case 'female':
        case 'f':
          return 2;
        default:
          return 0;
    }
  }

  /// 根据出生年份计算生肖
  ///
  /// 参数：
  /// - [birthDate] 出生日期
  ///
  /// 返回：生肖字符串
  static String getChineseZodiac(DateTime birthDate) {
    const zodiacAnimals = [
      '猴',
      '鸡',
      '狗',
      '猪',
      '鼠',
      '牛',
      '虎',
      '兔',
      '龙',
      '蛇',
      '马',
      '羊',
    ];
    return zodiacAnimals[birthDate.year % 12];
  }

  /// 根据出生日期计算年龄
  ///
  /// 参数：
  /// - [birthDate] 出生日期
  ///
  /// 返回：格式化的年龄字符串，如 "2岁3个月"、"5岁"，或 "未出生" (当出生日期在未来时)
  static String calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    
    // 如果出生日期在未来，返回 "未出生"
    if (birthDate.isAfter(now)) {
      return '未出生';
    }
    
    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;
    
    // 调整月数
    if (now.day < birthDate.day) {
      months--;
    }
    
    // 调整年数
    if (months < 0) {
      years--;
      months += 12;
    }
    
    // 如果年龄为 0 岁
    if (years == 0) {
      return months == 0 ? '未出生' : '$months个月';
    }
    
    // 如果月数为 0，只显示年龄
    if (months == 0) {
      return '$years岁';
    }
    
    // 显示年龄和月数
    return '$years岁$months个月';
  }

  /// 格式化日期为中文格式
  ///
  /// 参数：
  /// - [date] 日期
  ///
  /// 返回：格式化后的日期字符串，例如：2024年1月15日
  static String formatDateChinese(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  /// 将 DateTime 转为 YYYY-MM-DD 格式的字符串
  static String toYMD(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// 将 YYYY-MM-DD 格式的字符串转换为 DateTime（本地时区，若解析失败返回 null）
  static DateTime? fromYMD(String? ymd) {
    if (ymd == null) return null;
    final s = ymd.trim();
    if (s.isEmpty) return null;
    try {
      final parts = s.split('-');
      if (parts.length < 3) return null;
      final y = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final d = int.parse(parts[2]);
      return DateTime(y, m, d);
    } catch (e) {
      return null;
    }
  }

  /// 构建被照顾者完整信息字符串
  ///
  /// 参数：
  /// - [birthDate] 出生日期 (DateTime 格式)
  /// - [gender] 性别
  ///
  /// 返回：格式化的信息字符串，例如：1941年11月25日 · 蛇 · 84岁 · 女
  static String buildCareReceiverInfo({
    required DateTime? birthDate,
    required String? gender,
  }) {
    if (birthDate == null) {
      return getGenderText(gender);
    }

    final ageStr = calculateAge(birthDate);
    final zodiac = getChineseZodiac(birthDate);
    final genderText = getGenderText(gender);

    return '${formatDateChinese(birthDate)} · $zodiac · $ageStr · $genderText';
  }
}
