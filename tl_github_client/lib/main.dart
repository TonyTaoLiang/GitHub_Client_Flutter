import 'package:flutter/material.dart';
import 'package:github_client_app/common/ProfileChangeNotifier.dart';
import 'package:provider/provider.dart';
import './common/Global.dart';
import './routes/home_page.dart';
import './routes/LoginRoute.dart';

void main() => Global.init().then((value) => runApp(const MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeModel()),
        ChangeNotifierProvider(create: (_) => UserModel()),
        ChangeNotifierProvider(create: (_) => LocaleModel()),
      ],
      child: Consumer2<ThemeModel, LocaleModel>(
          builder: (BuildContext context, themeModel, localeModel, child) {
        return MaterialApp(
          theme: ThemeData(
            primarySwatch: themeModel.theme,
          ),
          home: const HomeRoute(),
          // 注册路由表
          routes: <String, WidgetBuilder>{
            "login": (context) => LoginRoute(),
          },
        );
      }),
    );
  }
}
