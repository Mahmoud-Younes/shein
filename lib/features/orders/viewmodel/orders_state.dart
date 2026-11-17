import 'package:equatable/equatable.dart';

import '../../../data/models/order_model.dart';

enum OrdersStatus { guest, loading, ready }

class OrdersState extends Equatable {
  const OrdersState({this.status = OrdersStatus.guest, this.orders = const []});

  final OrdersStatus status;
  final List<OrderModel> orders;

  bool get isGuest => status == OrdersStatus.guest;
  bool get isEmpty => status == OrdersStatus.ready && orders.isEmpty;

  @override
  List<Object?> get props => [status, orders];
}
