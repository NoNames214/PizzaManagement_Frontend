class ReviewRequest {
  final int pizzaId;
  final int orderDetailsId;
  final int rating;
  final String comment;

  ReviewRequest({
    required this.pizzaId,
    required this.rating,
    required this.comment,
    required this.orderDetailsId,
  });

  Map<String, dynamic> toJson() => {
    'pizzaId': pizzaId,
    'rating': rating,
    'comment': comment,
    'orderDetailsId': orderDetailsId,
  };
}