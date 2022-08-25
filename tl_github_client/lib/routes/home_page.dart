import 'package:flutter/material.dart';
import 'package:github_client_app/routes/LoginRoute.dart';
import 'package:provider/provider.dart';

import '../common/ProfileChangeNotifier.dart';
import '../models/repo.dart';
import '../common/Git.dart';
import '../models/user.dart';
import '../widgets/RepoItem.dart';

class HomeRoute extends StatefulWidget {
  const HomeRoute({super.key});

  @override
  State<HomeRoute> createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  static const loadingTag = "##loading##"; //表尾标记
  final _items = <Repo>[Repo()..name = loadingTag];
  bool hasMore = true; //是否还有数据
  int page = 1; //当前请求的是第几页

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("GitHub APP"),
        ),
        body: _buildBody(), // 构建主页面
        drawer: Drawer(//抽屉菜单
            child: Column(
          children: [
            Consumer<UserModel>(builder: ((context, value, child) {
              return Column(
                children: [
                  UserAccountsDrawerHeader(
                    accountName: Text(value.user!.name),
                    accountEmail: const Text(""),
                    //背景图片
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(
                              'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fi0.hdslb.com%2Fbfs%2Farticle%2Ff6e1a045e4b02129171bf40f74a415a477338e16.jpg&refer=http%3A%2F%2Fi0.hdslb.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1663340807&t=557e353c765359be0a8f88bc9bccb5a5'),
                          fit: BoxFit.fill),
                    ),

                    currentAccountPicture: CircleAvatar(
                      backgroundImage: NetworkImage(value.user!.avatar_url),
                    ),
                  ),
                  ListTile(
                    leading: const CircleAvatar(
                        child: Icon(Icons.power_settings_new)),
                    title: const Text('注销'),
                    onTap: () {
                      //点击操作
                      value.user = null;
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            })),
          ],
        )));
  }

  Widget _buildBody() {
    UserModel userModel = Provider.of<UserModel>(context);

    if (!userModel.isLogin) {
      return Center(
          child: ElevatedButton(
        child: const Text('登录'),
        onPressed: () => Navigator.of(context).pushNamed('login'),
      ));
    } else {
      return ListView.separated(
        itemCount: _items.length,
        separatorBuilder: (BuildContext context, int index) =>
            const Divider(height: 1.0),
        itemBuilder: (BuildContext context, int index) {
          //如果到了表尾
          if (_items[index].name == loadingTag) {
            //不足100条，继续获取数据
            if (hasMore) {
              //获取数据
              _retrieveData();
              //加载时显示loading
              return Container(
                padding: const EdgeInsets.all(16.0),
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 24.0,
                  height: 24.0,
                  child: CircularProgressIndicator(strokeWidth: 2.0),
                ),
              );
            } else {
              //已经加载了100条数据，不再获取数据。
              return Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16.0),
                child: const Text(
                  "没有更多了",
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }
          }
          //显示单词列表项
          return RepoItem(_items[index]);
        },
      );
    }
  }

  void _retrieveData() async {
    var data = await Git().getRepos(queryParameters: {
      'page': page,
      'page_size': 20,
    });

    //数据有20条
    hasMore = data.isNotEmpty && data.length % 20 == 0;

    setState(() {
      ttoast("$data");
      _items.insertAll(_items.length - 1, data);
      page++;
    });
  }
   
}
