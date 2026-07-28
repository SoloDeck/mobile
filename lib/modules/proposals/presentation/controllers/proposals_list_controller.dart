import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/modules/proposals/application/usecases/list_proposals_usecase.dart';
import 'package:solodesk_mobile/modules/proposals/domain/entities/proposal.dart';
import 'package:solodesk_mobile/modules/proposals/domain/value_objects/proposal_query.dart';
import 'package:solodesk_mobile/modules/proposals/domain/value_objects/proposal_status.dart';
import 'package:solodesk_mobile/modules/proposals/infrastructure/repository/proposals_repository_impl.dart';

part 'proposals_list_controller.g.dart';

const _pageSize = 20;

/// Bộ lọc cố định cho "Báo giá chờ duyệt": `sent` — đã gửi khách, đang chờ
/// khách phản hồi (chấp nhận/từ chối/hết hạn).
const _pendingFilter = ProposalListFilter(status: ProposalStatus.sent);

/// Accumulated state for the paginated pending-approval proposals list.
@immutable
class ProposalListState {
  const ProposalListState({
    required this.items,
    required this.page,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  final List<Proposal> items;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  ProposalListState copyWith({
    List<Proposal>? items,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
  }) => ProposalListState(
    items: items ?? this.items,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}

/// Drives the "Báo giá chờ duyệt" list: initial load, pull-to-refresh and
/// infinite scroll (load-more appends the next page). Always scoped to
/// [ProposalStatus.sent] — there is no filter switching for this screen.
@riverpod
class ProposalsListController extends _$ProposalsListController {
  @override
  Future<ProposalListState> build() => _fetchFirstPage();

  Future<ProposalListState> _fetchFirstPage() async {
    final useCase = ListProposalsUseCase(
      ref.read(proposalsRepositoryProvider),
    );
    final page = await useCase(
      filter: _pendingFilter,
      page: 1,
      pageSize: _pageSize,
    );
    return ProposalListState(
      items: page.items,
      page: page.page,
      hasMore: page.hasMore,
    );
  }

  /// Reloads the first page (pull-to-refresh).
  Future<void> refresh() async {
    state = await AsyncValue.guard(_fetchFirstPage);
  }

  /// Fetches and appends the next page. A failed load-more keeps the already
  /// loaded items intact — the user can pull-to-refresh to retry.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    state = AsyncValue.data(current.copyWith(isLoadingMore: true));
    final useCase = ListProposalsUseCase(
      ref.read(proposalsRepositoryProvider),
    );
    try {
      final next = await useCase(
        filter: _pendingFilter,
        page: current.page + 1,
        pageSize: _pageSize,
      );
      state = AsyncValue.data(
        current.copyWith(
          items: [...current.items, ...next.items],
          page: next.page,
          hasMore: next.hasMore,
          isLoadingMore: false,
        ),
      );
    } on Exception {
      state = AsyncValue.data(current.copyWith(isLoadingMore: false));
    }
  }
}
