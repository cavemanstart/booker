class ApiConfig {
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
  GetYzm,
  ConfirmYzm,
  ChangePassword,
  BooklistInit,
  BookInfo,
  SearchBook,
  Comment,
  Note,
  Analysis,
  User,
  Company,
  Tags,
  Register,
}
//使用：ApiTypeValues[APIType.Login]
const ApiTypeValues = {
  APIType.Login: ApiConfig.apiPrefix + ApiConfig.user + '/login',
  APIType.GetYzm: ApiConfig.apiPrefix + ApiConfig.user + '/auth-code',
  APIType.ConfirmYzm:
      ApiConfig.apiPrefix + ApiConfig.user + '/auth-code/confirm',
  APIType.ChangePassword: ApiConfig.apiPrefix + ApiConfig.user + '/password',
  APIType.BooklistInit: ApiConfig.apiPrefix + ApiConfig.book + '/list',
  APIType.BookInfo: ApiConfig.apiPrefix + ApiConfig.book,
  APIType.SearchBook: ApiConfig.apiPrefix + ApiConfig.book + '/list/search',
  APIType.Comment: ApiConfig.apiPrefix + ApiConfig.comment,
  APIType.Note: ApiConfig.apiPrefix + ApiConfig.note,
  APIType.Analysis: ApiConfig.apiPrefix + ApiConfig.analysis,
  APIType.User: ApiConfig.apiPrefix + ApiConfig.user,
  APIType.Company: ApiConfig.apiPrefix + ApiConfig.user+'/all-industries',
  APIType.Tags: ApiConfig.apiPrefix + ApiConfig.user+'/all-tags',
  APIType.Register: ApiConfig.apiPrefix + ApiConfig.user,
};

class Token {
  static String token = '';
}

class AgeData {
  static int year=21;
  static int month=1;
  static int day=1;
  static int age=21;
}
