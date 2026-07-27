import 'package:freezed_annotation/freezed_annotation.dart';

part 'proposal_content.freezed.dart';

/// Nội dung báo giá (`content` — cột JSONB tự do phía backend). AI generator
/// thật chỉ sinh đúng 7 khoá đầu (`project_overview` … `assumptions`); 3 khoá
/// còn lại (`revision_rounds`, `valid_until`, `total`) là khoá RIÊNG của
/// mobile, ghi thêm qua PATCH vì backend lưu nguyên si không lọc khoá lạ.
/// Mọi khoá lạ khác (không thuộc 10 khoá đã biết) được giữ nguyên trong
/// [unknown] để không bị mất khi ghi đè lại toàn bộ `content`.
@freezed
abstract class ProposalContent with _$ProposalContent {
  const factory ProposalContent({
    String? projectOverview,
    @Default(<String>[]) List<String> scopeOfWork,
    @Default(<String>[]) List<String> deliverables,
    String? timeline,
    String? pricing,
    String? paymentTerms,
    String? assumptions,
    int? revisionRounds,
    DateTime? validUntil,
    double? total,
    @Default(<String, dynamic>{}) Map<String, dynamic> unknown,
  }) = _ProposalContent;
}

/// 10 khoá `content` mà mobile biết cách đọc/ghi. Bất kỳ khoá nào khác đều
/// rơi vào [ProposalContent.unknown].
const _knownContentKeys = {
  'project_overview',
  'scope_of_work',
  'deliverables',
  'timeline',
  'pricing',
  'payment_terms',
  'assumptions',
  'revision_rounds',
  'valid_until',
  'total',
};

/// Chuỗi placeholder AI ghi nguyên văn khi thiếu thông tin — coi như trống.
const _missingPlaceholder = 'thông tin chưa được cung cấp';

/// Coi `null`, chuỗi rỗng (sau `.trim()`), hoặc placeholder AI (không phân
/// biệt hoa/thường) là trống -> `null`. Giá trị không phải String được ép
/// bằng `toString()` trước khi kiểm tra.
String? _str(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  if (s.isEmpty) return null;
  if (s.toLowerCase() == _missingPlaceholder) return null;
  return s;
}

/// List -> map từng phần tử sang String. String -> tách theo xuống dòng hoặc
/// dấu `;`, bỏ khoảng trắng thừa và phần tử rỗng. Kiểu khác -> danh sách rỗng.
List<String> _strList(dynamic v) {
  if (v is List) {
    return v.map((e) => e.toString()).toList();
  }
  if (v is String) {
    final s = _str(v);
    if (s == null) return <String>[];
    return s
        .split(RegExp(r'[\n;]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
  return <String>[];
}

/// `revision_rounds`: chấp nhận num hoặc String.
int? _int(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toInt();
  if (v is String) {
    final s = v.trim();
    if (s.isEmpty) return null;
    return int.tryParse(s) ?? num.tryParse(s)?.toInt();
  }
  return null;
}

/// `total`: chấp nhận num hoặc String.
double? _double(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) {
    final s = v.trim();
    if (s.isEmpty) return null;
    return num.tryParse(s)?.toDouble();
  }
  return null;
}

/// `valid_until`: chấp nhận String (ISO-8601, `DateTime.tryParse`) hoặc num
/// (epoch millis).
DateTime? _dateTime(dynamic v) {
  if (v == null) return null;
  if (v is String) {
    final s = v.trim();
    if (s.isEmpty) return null;
    return DateTime.tryParse(s);
  }
  if (v is num) return DateTime.fromMillisecondsSinceEpoch(v.toInt());
  return null;
}

extension ProposalContentX on ProposalContent {
  /// Chuyển content thành map JSON gửi lên backend qua PATCH. [unknown] được
  /// trải TRƯỚC, rồi 10 khoá đã biết ghi đè SAU — PATCH thay TOÀN BỘ content
  /// (không merge phía server) nên khoá lạ phải được giữ lại thủ công. Field
  /// nào `null` thì KHÔNG ghi vào map; hai field List (`scopeOfWork`,
  /// `deliverables`) không bao giờ null nên luôn được ghi (kể cả rỗng).
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{...unknown};
    map['scope_of_work'] = scopeOfWork;
    map['deliverables'] = deliverables;
    if (projectOverview != null) map['project_overview'] = projectOverview;
    if (timeline != null) map['timeline'] = timeline;
    if (pricing != null) map['pricing'] = pricing;
    if (paymentTerms != null) map['payment_terms'] = paymentTerms;
    if (assumptions != null) map['assumptions'] = assumptions;
    if (revisionRounds != null) map['revision_rounds'] = revisionRounds;
    if (validUntil != null) map['valid_until'] = validUntil!.toIso8601String();
    if (total != null) map['total'] = total;
    return map;
  }

  /// Factory tĩnh đặt trong extension (thay vì constructor phụ trên class do
  /// freezed sinh) để tránh đụng mã sinh `_$`. Gọi qua
  /// `ProposalContentX.fromMap(raw)`.
  ///
  /// 4 tầng phòng thủ vì `content` là JSONB tự do, backend không đảm bảo
  /// schema: (1) thiếu khoá -> null, không ném lỗi; (2) [_str] coi placeholder
  /// AI / rỗng là trống; (3) [_strList] chấp nhận cả List lẫn String tách
  /// dòng; (4) khoá lạ ngoài 10 khoá đã biết -> [ProposalContent.unknown].
  static ProposalContent fromMap(Map<String, dynamic> raw) {
    final unknown = <String, dynamic>{
      for (final entry in raw.entries)
        if (!_knownContentKeys.contains(entry.key)) entry.key: entry.value,
    };
    return ProposalContent(
      projectOverview: _str(raw['project_overview']),
      scopeOfWork: _strList(raw['scope_of_work']),
      deliverables: _strList(raw['deliverables']),
      timeline: _str(raw['timeline']),
      pricing: _str(raw['pricing']),
      paymentTerms: _str(raw['payment_terms']),
      assumptions: _str(raw['assumptions']),
      revisionRounds: _int(raw['revision_rounds']),
      validUntil: _dateTime(raw['valid_until']),
      total: _double(raw['total']),
      unknown: unknown,
    );
  }
}
