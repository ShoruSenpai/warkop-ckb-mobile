import 'api_exception.dart';

sealed class ApiResult<T> {
  const ApiResult();
}

final class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data);
  final T data;
}

final class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
}

T requireApiSuccess<T>(ApiResult<T> result) => switch (result) {
  ApiSuccess<T>(:final data) => data,
  ApiFailure<T>(:final message, :final statusCode) => throw ApiException(
    message,
    statusCode: statusCode,
  ),
};
