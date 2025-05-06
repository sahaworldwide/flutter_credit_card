class CreditCardModel {
  CreditCardModel(this.cardNumber, this.expiryMonth, this.expiryYear, this.cardHolderName,
      this.cvvCode, this.isCvvFocused);

  /// Number of the credit/debit card.
  String cardNumber = '';

  /// Expiry month of the card.
  String expiryMonth = '';

  /// Expiry year of the card.
  String expiryYear = '';

  /// Name of the card holder.
  String cardHolderName = '';

  /// Cvv code on card.
  String cvvCode = '';

  /// A boolean for indicating if cvv is focused or not.
  bool isCvvFocused = false;
}
