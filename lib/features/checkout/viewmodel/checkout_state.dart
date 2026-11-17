import 'package:equatable/equatable.dart';

enum CheckoutStatus { idle, submitting, placed, error }

class CheckoutState extends Equatable {
  const CheckoutState({
    this.status = CheckoutStatus.idle,
    this.placedOrderId,
    this.error,
  });

  final CheckoutStatus status;
  final String? placedOrderId;
  final String? error;

  bool get isSubmitting => status == CheckoutStatus.submitting;

  @override
  List<Object?> get props => [status, placedOrderId, error];
}
