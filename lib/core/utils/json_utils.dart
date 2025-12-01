/// JSON 解析工具类
/// 提供安全的类型转换方法，用于处理可能为字符串或数字的 JSON 值
class JsonUtils {
  JsonUtils._();

  /// 安全地将动态值转换为 int
  /// 支持 int、double、String 和 null 类型
  /// 
  /// 示例：
  /// - `parseInt(123)` => `123`
  /// - `parseInt(123.5)` => `123`
  /// - `parseInt("123")` => `123`
  /// - `parseInt(null)` => `null`
  /// - `parseInt("abc")` => `null`
  static int? parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  /// 安全地将动态值转换为 double
  /// 支持 double、int、String 和 null 类型
  /// 
  /// 示例：
  /// - `parseDouble(123.5)` => `123.5`
  /// - `parseDouble(123)` => `123.0`
  /// - `parseDouble("123.5")` => `123.5`
  /// - `parseDouble(null)` => `null`
  /// - `parseDouble("abc")` => `null`
  static double? parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }
}

