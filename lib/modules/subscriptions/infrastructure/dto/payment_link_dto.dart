import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_link_dto.freezed.dart';
part 'payment_link_dto.g.dart';

/// Wire shape của khối liên kết thanh toán gắn trong một payment intent.
///
/// LƯU Ý: `type` LUÔN LÀ `'checkout_url'` bất kể thực tế — xem docstring của
/// `PaymentLink` domain entity, KHÔNG BAO GIỜ switch theo `type`.
@freezed
abstract class PaymentLinkDto with _$PaymentLinkDto {
  const factory PaymentLinkDto({
    required String type,
    String? url,
    @JsonKey(name: 'qr_code_url') String? qrCodeUrl,
    String? instructions,
  }) = _PaymentLinkDto;

  factory PaymentLinkDto.fromJson(Map<String, dynamic> json) =>
      _$PaymentLinkDtoFromJson(json);
}
