import 'package:example/intl/locale_conf/intl_en.dart';
import 'package:example/intl/locale_conf/intl_zh.dart';
import 'package:example/locale_mock_api.dart';
import 'package:ez_intl/ez_intl.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

const defaultLocale = const Locale('en', 'US');

class MyApp extends StatelessWidget {
  MyApp({super.key});

  int lastLocaleTime = 0;
  static Locale currentLocales = defaultLocale;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(),
      localeResolutionCallback: (deviceLocale, supportedLocales) => onLocaleChanged(deviceLocale, supportedLocales),
      locale: defaultLocale,
      supportedLocales: [
        Locale.fromSubtags(languageCode: 'en'),
        Locale.fromSubtags(languageCode: 'zh'),
      ],
    );
  }

  Locale? onLocaleChanged(Locale? deviceLocale, Iterable<Locale> supportedLocales) {
    var current = DateTime.now().millisecondsSinceEpoch;
    var duration = current - lastLocaleTime;
    Locale? result;
    if (duration > 2000) {
      lastLocaleTime = current;
      debugPrint('deviceLocale: ${deviceLocale!.languageCode}, ${deviceLocale.countryCode}');
      currentLocales = deviceLocale;
      result = deviceLocale;
    } else {
      for (var locale in supportedLocales) {
        if (locale.languageCode == currentLocales.languageCode) {
          result = locale;
          break;
        }
      }
    }
    if (supportedLocales.where((lc) => lc.languageCode == result?.languageCode).isEmpty) {
      result = supportedLocales.firstOrNull;
    }
    if (result != null) {
      EZIntl.instance.onLocaleChanged(result!);
    }
    return result ?? deviceLocale;
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime dateTime = DateTime.now();
  late var localeChanged = () {
    setState(() {});
  };

  @override
  void initState() {
    super.initState();
    EZIntl.instance
      ..addLocaleChangeListener(localeChanged)
      ..init(
        localConfig: () async {
          return {'en': intl_en, 'zh': intl_zh};
        },
        intlLoader: (locale) async {
          return {};
          var localeConfig = await LocaleMockApi.getLocale(locale);
          return localeConfig ?? {};
        },
        defaultLocale: defaultLocale,
      );
  }

  void _incrementCounter() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    EZIntl.instance.removeLocaleChangeListener(localeChanged);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('demo_title'.intl),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: .center,
          children: [
            Text('hello'.intl),
            Text(
              'today_is'.intl.formatInject(
                names: ['day'],
                newStrings: [
                  'day${dateTime.weekday}'.intlPath(['week_locale']),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var localeConfig = await LocaleMockApi.getLocale(EZIntl.instance.currentLocale);
          EZIntl.instance.setNewLocale(localeConfig ?? {});
        },
        tooltip: 'tap_to_load_locale'.intl,
        child: const Icon(Icons.add),
      ),
    );
  }
}
