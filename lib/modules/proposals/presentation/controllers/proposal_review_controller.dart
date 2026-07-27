import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/modules/proposals/application/usecases/regenerate_proposal_content_usecase.dart';
import 'package:solodesk_mobile/modules/proposals/application/usecases/send_proposal_usecase.dart';
import 'package:solodesk_mobile/modules/proposals/application/usecases/update_proposal_content_usecase.dart';
import 'package:solodesk_mobile/modules/proposals/domain/entities/proposal_content.dart';
import 'package:solodesk_mobile/modules/proposals/infrastructure/repository/proposals_repository_impl.dart';
import 'package:solodesk_mobile/modules/proposals/presentation/providers/proposals_provider.dart';

part 'proposal_review_controller.g.dart';

/// Điều khiển ba hành động ghi trên MÀN 08: gửi khách, điền ô còn trống, sinh
/// lại nội dung bằng AI. Không giữ payload trả về — trạng thái chỉ là
/// `AsyncValue<void>`, UI đọc lại dữ liệu mới qua `proposalReviewProvider`
/// sau khi thành công.
@riverpod
class ProposalReviewController extends _$ProposalReviewController {
  @override
  FutureOr<void> build() {}

  Future<void> send(String id, String dealId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await SendProposalUseCase(ref.read(proposalsRepositoryProvider))(id);
      // send() có thể chuyển các báo giá "sent" khác cùng deal thành
      // "superseded" ở backend — invalidate CẢ HAI, không chỉ báo giá này.
      ref.invalidate(proposalDetailProvider(id));
      ref.invalidate(proposalReviewProvider(id));
      ref.invalidate(dealProposalsProvider(dealId));
    });
  }

  Future<void> fillGaps({
    required String id,
    required String dealId,
    required ProposalContent current,
    int? revisionRounds,
    DateTime? validUntil,
    double? total,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updated = current.copyWith(
        revisionRounds: revisionRounds ?? current.revisionRounds,
        validUntil: validUntil ?? current.validUntil,
        total: total ?? current.total,
      );
      await UpdateProposalContentUseCase(ref.read(proposalsRepositoryProvider))(
        id: id,
        dealId: dealId,
        content: updated,
      );
      ref.invalidate(proposalDetailProvider(id));
      ref.invalidate(proposalReviewProvider(id));
    });
  }

  Future<void> regenerate(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await RegenerateProposalContentUseCase(
        ref.read(proposalsRepositoryProvider),
      )(id);
      ref.invalidate(proposalDetailProvider(id));
      ref.invalidate(proposalReviewProvider(id));
    });
  }
}
