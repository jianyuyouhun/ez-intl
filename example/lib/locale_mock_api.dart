import 'dart:ui';

class LocaleMockApi {
  static Future<Map<String, dynamic>>? getLocale(Locale locale) async {
    await delay(() {}, milliseconds: 5000);
    if (locale.countryCode == 'en') {
      return {
        "hello": "Hello",
        "today_is": "Today is {day}, have a nice day"
      };
    } else {
      return {
        "hello": "你好",
        "today_is": "今天是{day}， 祝您一切顺利",
        "week_locale": {"day1":"星期一", "day2": "星期二", "day3": "周三", "day4": "周四", "day5": "周五", "day6": "周六", "day7": "周日"},
      };
    }
  }
}

typedef DelayCallback<T> = T Function();

Future<T> delay<T>(DelayCallback<T> callback, {int milliseconds = 16}) async {
  await Future.delayed(Duration(milliseconds: milliseconds), () => () {});
  return callback.call();
}
