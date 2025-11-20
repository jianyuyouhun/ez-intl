<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

TODO: Put a short description of the package here that helps potential users
know whether this package might be useful for them.

## Features

实现了简单的国际化方案，支持后段api返回国际化配置动态变更，思路来源于Getx的国际化。

## Getting started

todo 还在完善发布流程

## Usage

### 1. todo 依赖本项目，pub.dev还没ready，可以直接url依赖

### 2. 在MaterialApp里配置

```
  localeResolutionCallback: (deviceLocale, supportedLocales) => onLocaleChanged(deviceLocale, supportedLocales),
      locale: defaultLocale,
      supportedLocales: [
        Locale.fromSubtags(languageCode: 'en'),
        Locale.fromSubtags(languageCode: 'zh'),
      ],
```

onLocaleChanged里面调用EZIntl.instance.onLocaleChanged(result!); 这里逻辑可以参考example，主要是有些手机切换语言后回调不一定及时，有些机型会回调多次。



### 3. 初始化

```EZIntl.instance
      .init(
        localConfig: () async {
          return {'en': intl_en, 'zh': intl_zh};//配置语言intl_en为map，可以多层结构，参考example
        },
        intlLoader: (locale) async {
          return {};可以在此执行api请求加载动态国际化配置，也可以直接返回{}使用localConfig。二者会自动merge
          var localeConfig = await LocaleMockApi.getLocale(locale);
          return localeConfig ?? {};
        },
        defaultLocale: defaultLocale,
      );
```


### 4. 使用

在Widget基类里添加localeChangeListener，也可以在状态管理里操作。

使用的时候`'hello'.intl`表示读取localeMap['hello']的结果，除此之外还支持字符串替换，多层结构读取，参考example代码

## Additional information

时间仓促，还在完善，目前仅供参考
