import 'package:pizza_management/data/model/pizza.dart';
import 'package:pizza_management/data/model/user.dart';
import 'order_details.dart';

class Review {
  final int id;
  final int userId;
  final int orderDetailsId;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final User ? user;
  final Pizza ? pizza;
  final OrderDetails ? orderDetails;

  Review({
    required this.id,
    required this.userId,
    required this.orderDetailsId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.user,
    this.pizza,
    this.orderDetails,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Review && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      userId: json['userId'],
      orderDetailsId: json['orderDetailsId'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
      user: json['userResponse'] != null ? User.fromJson(json['userResponse']) : null,
      pizza: json['pizzaResponse'] != null ? Pizza.fromJson(json['pizzaResponse']) : null,
      orderDetails: json['orderDetailsResponse'] != null ? OrderDetails.fromJson(json['orderDetailsResponse']) : null,
    );
  }

  @override
  String toString () => 'Review(id : $id, userId : $userId, orderDetailIds : $orderDetailsId)';
}