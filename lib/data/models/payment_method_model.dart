class PaymentMethodModel {
  final int id;
  final String name;
  final String accountNumber;
  final String accountHolder;
  final String? logoUrl;

  PaymentMethodModel({
    required this.id,
    required this.name,
    required this.accountNumber,
    required this.accountHolder,
    this.logoUrl,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'],
      name: json['name'],
      accountNumber: json['account_number'],
      accountHolder: json['account_holder'],
      logoUrl: json['logo_url'],
    );
  }
}
