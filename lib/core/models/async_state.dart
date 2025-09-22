import 'package:freezed_annotation/freezed_annotation.dart';
import 'app_error.dart';

part 'async_state.freezed.dart';
part 'async_state.g.dart';

/// Generic async state wrapper for handling loading, success, and error states
/// This provides consistent state management across all async operations
@Freezed(genericArgumentFactories: true)
sealed class AsyncState<T> with _$AsyncState<T> {
  /// Loading state - operation in progress
  const factory AsyncState.loading() = AsyncLoading<T>;
  
  /// Success state - operation completed successfully
  const factory AsyncState.success(T data) = AsyncSuccess<T>;
  
  /// Error state - operation failed
  const factory AsyncState.error(AppError error) = AsyncError<T>;

  factory AsyncState.fromJson(Map<String, dynamic> json, T Function(Object?) fromJsonT) =>
      _$AsyncStateFromJson(json, fromJsonT);
}

/// Extension methods for AsyncState to make it easier to work with
extension AsyncStateExtensions<T> on AsyncState<T> {
  /// Check if the state is loading
  bool get isLoading => this is AsyncLoading<T>;
  
  /// Check if the state has data
  bool get hasData => this is AsyncSuccess<T>;
  
  /// Check if the state has an error
  bool get hasError => this is AsyncError<T>;
  
  /// Get the data if available, null otherwise
  T? get data => switch (this) {
    AsyncSuccess<T> success => success.data,
    _ => null,
  };
  
  /// Get the error if available, null otherwise
  AppError? get error => switch (this) {
    AsyncError<T> error => error.error,
    _ => null,
  };
  
  /// Transform the data if in success state
  AsyncState<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      AsyncSuccess<T> success => AsyncSuccess(transform(success.data)),
      AsyncLoading<T> _ => AsyncLoading<R>(),
      AsyncError<T> error => AsyncError<R>(error.error),
    };
  }
  
  /// Handle different states with callbacks
  R when<R>({
    required R Function() loading,
    required R Function(T data) success,
    required R Function(AppError error) error,
  }) {
    if (this is AsyncLoading<T>) {
      return loading();
    } else if (this is AsyncSuccess<T>) {
      return success((this as AsyncSuccess<T>).data);
    } else if (this is AsyncError<T>) {
      return error((this as AsyncError<T>).error);
    }
    throw StateError('Unknown AsyncState type');
  }
}
