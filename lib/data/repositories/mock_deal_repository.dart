import 'dart:math';

import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/data/mock_data/mock_data.dart';
import 'package:mobile/domain/models/deal.dart';
import 'package:mobile/domain/repositories/deal_repository.dart';

/// Mock implementation của [DealRepository].
///
/// Giả lập network latency 1s và random error 10%.
class MockDealRepository implements DealRepository {
  final _random = Random();

  final List<Deal> _deals = List.from(MockData.deals);

  /// Giả lập lỗi mạng ngẫu nhiên.
  void _maybeThrowError() {
    if (_random.nextDouble() < AppConstants.mockErrorRate) {
      throw Exception('Lỗi kết nối mạng. Vui lòng thử lại.');
    }
  }

  @override
  Future<List<Deal>> getDeals() async {
    await Future.delayed(AppConstants.mockNetworkDelay);
    _maybeThrowError();
    return List.unmodifiable(_deals);
  }

  @override
  Future<List<Deal>> getDealsByStage(String stageId) async {
    await Future.delayed(AppConstants.mockNetworkDelay);
    _maybeThrowError();
    return _deals.where((d) => d.stageId == stageId).toList();
  }

  @override
  Future<Deal> getDealById(String id) async {
    await Future.delayed(AppConstants.mockNetworkDelay);
    _maybeThrowError();
    try {
      return _deals.firstWhere((d) => d.id == id);
    } catch (_) {
      throw Exception('Không tìm thấy deal.');
    }
  }

  @override
  Future<Deal> updateDealStage(String dealId, String newStageId) async {
    await Future.delayed(AppConstants.mockNetworkDelay);
    _maybeThrowError();

    final index = _deals.indexWhere((d) => d.id == dealId);
    if (index == -1) throw Exception('Không tìm thấy deal.');

    final updated = _deals[index].copyWith(
      stageId: newStageId,
      updatedAt: DateTime.now(),
    );
    _deals[index] = updated;
    return updated;
  }
}
