import 'package:dio/dio.dart';
import 'package:github_client_app/common/ProfileChangeNotifier.dart';

import '../common/Git.dart';
import '../models/index.dart';
import 'package:flutter/material.dart';
import '../common/Global.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginRoute extends StatefulWidget {
  @override
  _LoginRouteState createState() => _LoginRouteState();
}

class _LoginRouteState extends State<LoginRoute> {
  TextEditingController _unameController = TextEditingController();
  TextEditingController _pwdController = TextEditingController();
  bool pwdShow = false;
  GlobalKey _formKey = GlobalKey<FormState>();
  bool _nameAutoFocus = true;

  @override
  void initState() {
    // 自动填充上次登录的用户名，填充后将焦点定位到密码输入框
    _unameController.text = Global.profile.lastLogin ?? "";
    if (_unameController.text.isNotEmpty) {
      _nameAutoFocus = false;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // var gm = GmLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: <Widget>[
              TextFormField(
                  autofocus: _nameAutoFocus,
                  controller: _unameController,
                  decoration: InputDecoration(
                    labelText: '用户名', //gm.userName,
                    hintText: '用户名', //gm.userName,
                    prefixIcon: Icon(Icons.person),
                  ),
                  // 校验用户名（不能为空）
                  validator: (v) {
                    return v == null || v.trim().isNotEmpty
                        ? null
                        : '密码不能为空'; //gm.userNameRequired;
                  }),
              TextFormField(
                controller: _pwdController,
                autofocus: !_nameAutoFocus,
                decoration: InputDecoration(
                    labelText: '密码', //gm.password,
                    hintText: '密码', //gm.password,
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                          pwdShow ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          pwdShow = !pwdShow;
                        });
                      },
                    )),
                obscureText: !pwdShow,
                //校验密码（不能为空）
                validator: (v) {
                  return v == null || v.trim().isNotEmpty
                      ? null
                      : '密码不能为空'; //gm.passwordRequired;
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 25),
                child: ConstrainedBox(
                  constraints: BoxConstraints.expand(height: 55.0),
                  child: ElevatedButton(
                    // color: Theme.of(context).primaryColor,
                    onPressed: _onLogin,
                    // textColor: Colors.white,
                    child: Text('登陆'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onLogin() async {
    // 先验证各个表单字段是否合法
    if ((_formKey.currentState as FormState).validate()) {
      // showLoading(context);
      User? user;
      try {
        _unameController.text = '273940341@qq.com';
        _pwdController.text = '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';
        user = await Git(context)
            .login(_unameController.text, _pwdController.text);

        // Future.delayed(const Duration(seconds: 2));

        // 此句解决Do not use BuildContexts across async gaps
        // Provider.of正在异步方法中使用上下文。执行此方法时，上下文可能会更改。
        if (!mounted) return;
        // 登录页返回后，首页会build，传false即可，更新user后不触发更新
        Provider.of<UserModel>(context, listen: false).user = user;
      } on DioError catch (e) {
        //登录失败则提示
        if (e.response?.statusCode == 401) {
          ttoast('用户密码错误');
        } else {
          ttoast('登录失败\n${e.toString()}');
        }
      } finally {
        // 隐藏loading框
        // Navigator.of(context).pop();
      }
      //登录成功则返回
      if (user != null) {
        if (!mounted) return;
        Navigator.of(context).pop();
      }
    }
  }
}

void ttoast(String string) {
  Fluttertoast.showToast(
      msg: string,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}
