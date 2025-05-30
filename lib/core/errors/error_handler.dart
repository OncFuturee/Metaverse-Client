import 'package:dio/dio.dart';
import 'failure.dart';

class ErrorHandler {
  static Failure handleError(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    }
    return const ServerFailure(message: '未知错误');
  }

  static Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(message: '网络连接超时');
      case DioExceptionType.connectionError:
        return const NetworkFailure(message: '网络连接失败');
      default:
        return ServerFailure(
          message: error.response?.statusMessage ?? '服务器错误',
          code: error.response?.statusCode?.toString(),
        );
    }
  }
}
