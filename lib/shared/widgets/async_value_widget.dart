import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk_mobile/shared/widgets/error_retry_widget.dart';
import 'package:solodesk_mobile/shared/widgets/loading_shimmer.dart';

class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
    this.loadingWidget,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;
  final Widget? loadingWidget;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => loadingWidget ?? const LoadingShimmer(),
      error: (error, _) => ErrorRetryWidget(
        message: error.toString(),
        onRetry: onRetry ?? () {},
      ),
    );
  }
}
