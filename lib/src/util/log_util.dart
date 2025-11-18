import 'dart:developer';

/**
 * @Author: wangyu
 * @Description: Log Util.
 * @Date: 2023/12/05
 */
typedef LogBuilder = Object? Function();

logD(LogBuilder builder, {String? tag}) {
  AppLogUtil.d(builder, tag: tag);
}

logE(LogBuilder builder, {String? tag}) {
  AppLogUtil.e(builder, tag: tag);
}

logV(LogBuilder builder, {String? tag}) {
  AppLogUtil.v(builder, tag: tag);
}

/// App Log Util.
class AppLogUtil {
  static const String _defTag = 'app';
  static bool _debugMode = true; //是否是debug模式,true: log v 不输出.
  static int _maxLen = 128;
  static String _tagValue = _defTag;

  static void init({
    String tag = _defTag,
    bool isDebug = true,
    int maxLen = 128,
  }) {
    _tagValue = tag;
    _debugMode = isDebug;
    _maxLen = maxLen;
  }


  static void d(LogBuilder builder, {String? tag}) {
    if (_debugMode) {
      log('$tag d | ${builder.call()?.toString()}');
    }
  }

  static void e(LogBuilder builder, {String? tag}) {
    _printLog(tag, ' e ', builder);
  }

  static void v(LogBuilder builder, {String? tag}) {
    if (_debugMode) {
      _printLog(tag, ' v ', builder);
    }
    // _recordFile(builder, tag: tag);
  }

  static void _printLog(String? tag, String stag, LogBuilder builder) {
    String da = builder.call()?.toString() ?? 'null';
    tag = tag ?? _tagValue;
    if (da.length <= _maxLen) {
      print('$tag$stag $da');
      return;
    }
    print('$tag$stag — — — — — — — — — — — — — — — — st — — — — — — — — — — — — — — — —');
    while (da.isNotEmpty) {
      if (da.length > _maxLen) {
        print('$tag$stag| ${da.substring(0, _maxLen)}');
        da = da.substring(_maxLen, da.length);
      } else {
        print('$tag$stag| $da');
        da = '';
      }
    }
    print('$tag$stag — — — — — — — — — — — — — — — — ed — — — — — — — — — — — — — — — —');
  }
}
