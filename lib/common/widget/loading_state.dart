import 'package:flutter/material.dart';

/// 加载状态枚举
enum LoadingStatus { loading, success, error }

/// 加载状态类
class LoadingState<T> {
  final LoadingStatus status;
  final T? data;
  final String? errorMessage;

  LoadingState._(this.status, {this.data, this.errorMessage});

  /// 加载中状态
  factory LoadingState.loading() => LoadingState._(LoadingStatus.loading);

  /// 成功状态
  factory LoadingState.success(T data) => LoadingState._(
        LoadingStatus.success,
        data: data,
      );

  /// 错误状态
  factory LoadingState.error(String errorMessage) => LoadingState._(
        LoadingStatus.error,
        errorMessage: errorMessage,
      );

  /// 是否为加载中状态
  bool get isLoading => status == LoadingStatus.loading;

  /// 是否为成功状态
  bool get isSuccess => status == LoadingStatus.success;

  /// 是否为错误状态
  bool get isError => status == LoadingStatus.error;
}