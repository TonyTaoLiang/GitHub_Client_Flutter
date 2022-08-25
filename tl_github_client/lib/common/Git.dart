import 'dart:async';
import 'dart:convert';
// import 'dart:html';
import 'dart:io';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:github_client_app/common/Global.dart';
import 'package:github_client_app/routes/LoginRoute.dart';
import '../models/index.dart';
export 'package:dio/dio.dart' show DioError;
import 'package:fluttertoast/fluttertoast.dart';

class Git {
  BuildContext? context;
  late Options _options;

  // 网络请求过程中可能会需要使用当前的context信息，比如在请求失败时
  // 打开一个新路由，而打开新路由需要context信息。
  Git([this.context]) {
    _options = Options(extra: {"context": context});
  }

  static Dio dio =
      Dio(BaseOptions(baseUrl: 'https://api.github.com/', headers: {
    HttpHeaders.acceptHeader: "application/vnd.github.squirrel-girl-preview,"
        "application/vnd.github.symmetra-preview+json"
  }));

  static void init() {
    // 添加缓存插件
    // dio.interceptors.add(Global.netCache);
    //设置用户token（可能为null，代表未登录）
    dio.options.headers[HttpHeaders.authorizationHeader] = Global.profile.token;

    // 在调试模式下需要抓包调试，使用代理，禁用HTTPS证书校验
    if (!Global.isRelease) {
      //chrome上运行，浏览器限制跨域了，报错
      //Expected a value of type 'DefaultHttpClientAdapter', but got one of type 'BrowserHttpClientAdapter'
      //Flutter Web 跨域问题解决方案https://juejin.cn/post/6844904080179986440
      //BrowserHttpClientAdapter DefaultHttpClientAdapter
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        // client.findProxy = (uri) {
        //   return "PROXY 10.95.249.53:8888";
        // };
        //禁用HTTPS证书校验
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
      };
    }
  }

  // 登录接口，登录成功后返回用户信息
  Future<User> login(String login, String pwd) async {
    String basic = 'Basic ' + base64.encode(utf8.encode('$login:$pwd'));

    var r = await dio.get(
      "/user",
      options: _options.copyWith(headers: {
        HttpHeaders.authorizationHeader: basic
      }, extra: {
        "noCache": true, //此接口禁用缓存
      }),
    );

    //登录成功后更新公共头（authorization），此后的所有请求都会带上用户身份信息
    dio.options.headers[HttpHeaders.authorizationHeader] = basic;
    //清空所有缓存
    // Global.netCache.cache.clear();
    //更新profile中的token信息
    Global.profile.token = basic;

    // if (kDebugMode) {
    //   print('${r.data}');
    // }

    return User.fromJson(r.data);
  }

  //获取用户项目列表
  Future<List<Repo>> getRepos({
    Map<String, dynamic>? queryParameters, //query参数，用于接收分页信息
    refresh = false,
  }) async {
    if (refresh) {
      // 列表下拉刷新，需要删除缓存（拦截器中会读取这些信息）
      _options.extra!.addAll({"refresh": true, "list": true});
    }
    var r = await dio.get<List>(
      "user/repos",
      queryParameters: queryParameters,
      options: _options,
    );
    return r.data!.map((e) => Repo.fromJson(e)).toList();
  }
}
