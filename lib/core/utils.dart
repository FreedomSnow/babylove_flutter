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
