import 'package:dio/dio.dart';
import 'package:github_client_app/common/Global.dart';
import '../models/index.dart';
import 'dart:collection';

class CacheObject {
  CacheObject(this.response)
      //冒号的作用就是初始化。 在执行构造函数体之前,初始化实例变量.
      //: super(key: key)这就是调用父类去初始化key
      : timeStamp = DateTime.now().millisecondsSinceEpoch;
  Response response;
  int timeStamp; // 缓存创建时间

  @override
  bool operator ==(other) {
    return response.hashCode == other.hashCode;
  }

  //将请求uri作为缓存的key
  @override
  int get hashCode => response.realUri.hashCode;
}

class NetCache extends Interceptor {
  var cache = LinkedHashMap<String, CacheObject>();

  void delete(String key) {
    cache.remove(key);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    super.onRequest(options, handler);

    if (!Global.profile.cache!.enable) {
      handler.next(options);
    }

    //dio包的option.extra是专门用于扩展请求参数的
    //refresh	bool	如果为true，则本次请求不使用缓存，但新的请求结果依然会被缓存
    //noCache	bool	本次请求禁用缓存，请求结果也不会被缓存。
    bool refresh = options.extra['refresh'] == true;

    if (refresh) {
      if (options.extra["list"] == true) {
        //若是列表，则只要url中包含当前path的缓存全部删除（简单实现，并不精准）
        cache.removeWhere((key, value) => key.contains(options.path));
      } else {
        delete(options.uri.toString());
      }

      return handler.next(options);
    }

    if (options.extra["noCache"] != true &&
        options.method.toLowerCase() == 'get') {
      String key = options.extra["cacheKey"] ?? options.uri.toString();
      var ob = cache[key];

      if (ob != null) {
        if ((DateTime.now().millisecondsSinceEpoch - ob.timeStamp) / 1000 <
            Global.profile.cache!.maxAge) {
          //缓存未过期
          return handler.resolve(ob.response);
        } else {
          cache.remove(key);
        }
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {

    super.onResponse(response, handler);

    _saveCache(Response object) {
      RequestOptions options = object.requestOptions;

      if (options.extra["noCache"] != true &&
          options.method.toLowerCase() == 'get') {
        if (cache.length > Global.profile.cache!.maxCount) {
          //缓存数量超出，删除最早的一条
          cache.remove(cache[cache.keys.first]);
        }
        String key = options.extra["cacheKey"] ?? options.uri.toString();
        cache[key] = CacheObject(object);
      }
    }
  }
}
