import 'dart:math';
import 'dart:ui';

import 'package:ez_intl/src/util/log_util.dart' show logD, AppLogUtil;

///
/// @Author: wangyu
/// @Date: 2024/7/13
///
/// FlutterIntl
typedef DefaultIntlConfig = Future<Map<String, Map<String, dynamic>>> Function();

class EZIntl {
  factory EZIntl() => _getInstance();

  static EZIntl get instance => _getInstance();
  static EZIntl? _instance;
  late IntlLoader intlLoader;
  Map<String, dynamic> _localeMap = {};
  Map<String, Map<String, dynamic>> _localLocale = {};
  bool _initialized = false;

  late Locale currentLocale;
  // 添加一个回调函数列表
  final List<VoidCallback> _listeners = [];

  // 注册监听器的方法
  void addLocaleChangeListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  // 移除监听器的方法
  void removeLocaleChangeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  EZIntl._internal() {}

  Future init({required DefaultIntlConfig localConfig, required IntlLoader intlLoader, required Locale defaultLocale, bool log = true}) async {
    AppLogUtil.init(tag: 'ez-intl', isDebug: log, maxLen: 256);
    this.intlLoader = intlLoader;
    _initialized = true;
    _localLocale = await localConfig.call();
    _localeMap = await intlLoader(defaultLocale);
  }

  Future onLocaleChanged(Locale locale) async {
    if (!_initialized) {
      return;
    }
    currentLocale = locale;
    Map<String, dynamic> localLocale = _localLocale[locale.languageCode] ?? _localLocale['en'] ?? {};
    _localeMap = {...localLocale};
    var customMap = await intlLoader.call(locale);
    logD(() => 'check overridden intl key-value');
    customMap.forEach((key, value) {
      if (localLocale.containsKey(key)) {
        var oldMap = localLocale[key];
        if (oldMap is Map && value is Map) {
          customMap[key] = {...oldMap, ...value};
          logD(() => 'merge intl key $key\'s value $oldMap with value $value');
        } else {
          logD(() => 'overridden intl key $key\'s value $oldMap with value $value');
        }
      }
    });
    logD(() => '-------------------------------');
    _localeMap = {...localLocale, ...customMap};
    // 替代 EventBus 的通知方式
    for (var listener in _listeners) {
      listener.call();
    }
  }

  Future setNewLocale(Map<String, dynamic> localeConfig) async {
    Map<String, dynamic> localLocale = _localLocale[currentLocale.languageCode] ?? _localLocale['en'] ?? {};
    _localeMap = {...localLocale};
    logD(() => 'check overridden intl key-value');
    localeConfig.forEach((key, value) {
      if (localLocale.containsKey(key)) {
        var oldMap = localLocale[key];
        if (oldMap is Map && value is Map) {
          localeConfig[key] = {...oldMap, ...value};
          logD(() => 'merge intl key $key\'s value $oldMap with value $value');
        } else {
          logD(() => 'overridden intl key $key\'s value $oldMap with value $value');
        }
      }
    });
    logD(() => '-------------------------------');
    _localeMap = {...localLocale, ...localeConfig};
    // 替代 EventBus 的通知方式
    for (var listener in _listeners) {
      listener.call();
    }
  }

  static EZIntl _getInstance() {
    _instance ??= EZIntl._internal();
    return _instance!;
  }

  String getIntlValue(String key, [List<String>? paths]) {
    var intlValue = _intlValue(_localeMap, key, paths);
    if (intlValue == null) {
      return _intlValue(_localeMap['en']!, key, paths) ?? key;
    } else {
      return intlValue;
    }
  }

  String? _intlValue(Map<String, dynamic> localeMap, String key, [List<String>? paths]) {
    if (paths == null) {
      return localeMap[key]?.toString() ?? localeMap['key']?[key]?.toString();
    }
    dynamic map;
    for (var p in paths) {
      if (map == null) {
        map = localeMap[p];
      } else {
        map = map[p];
      }
    }
    if (map == null) {
      return null;
    } else {
      return map[key]?.toString();
    }
  }
}

typedef IntlLoader = Future<Map<String, dynamic>> Function(Locale locale);

extension StringEx on String {
  String get intl {
    return EZIntl.instance.getIntlValue(this);
  }

  String intlPath([List<String>? paths]) => EZIntl.instance.getIntlValue(this, paths);

  String formatInject({required List<String> names, required List<String> newStrings}) {
    if (newStrings.isEmpty) {
      return this;
    }
    String result = this;
    var length = min(newStrings.length, names.length);
    for (int i = 0; i < length; i++) {
      result = result.replaceAll('{${names[i]}}', newStrings[i]);
    }
    return result;
  }
}
