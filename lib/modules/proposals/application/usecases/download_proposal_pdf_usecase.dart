import 'package:solodesk_mobile/modules/proposals/domain/repositories/proposals_repository.dart';

class DownloadProposalPdfUseCase {
  const DownloadProposalPdfUseCase(this._repository);

  final ProposalsRepository _repository;

  Future<List<int>> call(String id) => _repository.downloadPdf(id);
}
