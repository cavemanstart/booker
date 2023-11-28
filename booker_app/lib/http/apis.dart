class APIs {
  //url 前缀
  static const String apiPrefix = 'http://47.117.112.114:5000';
  static const String user = '/user';
  static const String book = '/book';
  static const String comment = '/comment';
  static const String analysis = '/analysis';
  static const String note = '/note';
}

//接口类型,依次往下加
enum APIType {
  Login,
}
//使用：APITypeValues[APIType.Login]
const APITypeValues = {
  APIType.Login: APIs.apiPrefix + APIs.user + '/login',
};
