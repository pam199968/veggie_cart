import '../models/order_model.dart';
import '../models/user_model.dart';

class OrderModelWithCustomer {
  final OrderModel order;
  final UserModel? customer;

  OrderModelWithCustomer({
    required this.order,
    required this.customer,
  });
}
