import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../flutter_credit_card.dart';
import 'masked_text_controller.dart';
import 'utils/constants.dart';
import 'utils/helpers.dart';
import 'utils/typedefs.dart';
import 'utils/validators.dart';

class CreditCardForm extends StatefulWidget {
  const CreditCardForm({
    required this.cardNumber,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cardHolderName,
    required this.cvvCode,
    required this.onCreditCardModelChange,
    required this.formKey,
    this.obscureCvv = false,
    this.obscureNumber = false,
    this.inputConfiguration = const InputConfiguration(),
    this.cardNumberKey,
    this.cardHolderKey,
    this.expiryMonthKey,
    this.expiryYearKey,
    this.cvvCodeKey,
    this.cvvValidationMessage = AppConstants.cvvValidationMessage,
    this.dateValidationMessage = AppConstants.dateValidationMessage,
    this.numberValidationMessage = AppConstants.numberValidationMessage,
    this.isHolderNameVisible = true,
    this.isCardNumberVisible = true,
    this.isExpiryDateVisible = true,
    this.enableCvv = true,
    this.autovalidateMode,
    this.cardNumberValidator,
    this.expiryMonthValidator,
    this.expiryYearValidator,
    this.cvvValidator,
    this.cardHolderValidator,
    this.onFormComplete,
    this.disableCardNumberAutoFillHints = false,
    this.isCardHolderNameUpperCase = false,
    super.key,
  });

  /// A string indicating card number in the text field.
  final String cardNumber;

  /// A string indicating expiry month in the text field.
  final String? expiryMonth;

  /// A string indicating expiry year in the text field.
  final String? expiryYear;

  /// A string indicating card holder name in the text field.
  final String cardHolderName;

  /// A string indicating cvv code in the text field.
  final String cvvCode;

  /// Error message string when invalid cvv is entered.
  final String cvvValidationMessage;

  /// Error message string when invalid expiry date is entered.
  final String dateValidationMessage;

  /// Error message string when invalid credit card number is entered.
  final String numberValidationMessage;

  /// Provides callback when there is any change in [CreditCardModel].
  final CCModelChangeCallback onCreditCardModelChange;

  /// When enabled cvv gets hidden with obscuring characters. Defaults to
  /// false.
  final bool obscureCvv;

  /// When enabled credit card number get hidden with obscuring characters.
  /// Defaults to false.
  final bool obscureNumber;

  /// Allow editing the holder name by enabling this in the credit card form.
  /// Defaults to true.
  final bool isHolderNameVisible;

  /// Allow editing the credit card number by enabling this in the credit
  /// card form. Defaults to true.
  final bool isCardNumberVisible;

  /// Allow editing the cvv code by enabling this in the credit card form.
  /// Defaults to true.
  final bool enableCvv;

  /// Allows editing the expiry date by enabling this in the credit
  /// card form. Defaults to true.
  final bool isExpiryDateVisible;

  /// A form state key for this credit card form.
  final GlobalKey<FormState> formKey;

  /// Provides a callback when text field provides callback in
  /// [onEditingComplete].
  final Function? onFormComplete;

  /// A FormFieldState key for card number text field.
  final GlobalKey<FormFieldState<String>>? cardNumberKey;

  /// A FormFieldState key for card holder text field.
  final GlobalKey<FormFieldState<String>>? cardHolderKey;

  /// A FormFieldState key for expiry month text field.
  final GlobalKey<FormFieldState<String>>? expiryMonthKey;

  /// A FormFieldState key for expiry year text field.
  final GlobalKey<FormFieldState<String>>? expiryYearKey;

  /// A FormFieldState key for cvv code text field.
  final GlobalKey<FormFieldState<String>>? cvvCodeKey;

  /// Provides [InputDecoration] and [TextStyle] to [CreditCardForm]'s [TextField].
  final InputConfiguration inputConfiguration;

  /// Used to configure the auto validation of [FormField] and [Form] widgets.
  final AutovalidateMode? autovalidateMode;

  /// A validator for card number text field.
  final ValidationCallback? cardNumberValidator;

  /// A validator for expiry month.
  final ValidationCallback? expiryMonthValidator;

  /// A validator for expiry year.
  final ValidationCallback? expiryYearValidator;

  /// A validator for cvv code text field.
  final ValidationCallback? cvvValidator;

  /// A validator for card holder text field.
  final ValidationCallback? cardHolderValidator;

  /// Setting this flag to true will disable autofill hints for Credit card
  /// number text field. Flutter has a bug when auto fill hints are enabled for
  /// credit card numbers it shows keyboard with characters. But, disabling
  /// auto fill hints will show correct keyboard.
  ///
  /// Defaults to false.
  ///
  /// You can follow the issue here
  /// [https://github.com/flutter/flutter/issues/104604](https://github.com/flutter/flutter/issues/104604).
  final bool disableCardNumberAutoFillHints;

  /// When true card holder field will make all the input value to uppercase
  final bool isCardHolderNameUpperCase;

  @override
  State<CreditCardForm> createState() => _CreditCardFormState();
}

class _CreditCardFormState extends State<CreditCardForm> {
  late String cardNumber;
  String? expiryMonth;
  String? expiryYear;
  late String cardHolderName;
  late String cvvCode;
  bool isCvvFocused = false;

  late final CreditCardModel creditCardModel;
  late final CCModelChangeCallback onCreditCardModelChange =
      widget.onCreditCardModelChange;

  late final MaskedTextController _cardNumberController = MaskedTextController(
    mask: AppConstants.cardNumberMask,
    text: widget.cardNumber,
  );

  late final TextEditingController _cardHolderNameController = TextEditingController(
    text: widget.cardHolderName,
  );

  late final TextEditingController _cvvCodeController = MaskedTextController(
    mask: AppConstants.cvvMask,
    text: widget.cvvCode,
  );

  final FocusNode cvvFocusNode = FocusNode();
  final FocusNode expiryMonthNode = FocusNode();
  final FocusNode expiryYearNode = FocusNode();
  final FocusNode cardHolderNode = FocusNode();

  @override
  void initState() {
    super.initState();
    createCreditCardModel();
    cvvFocusNode.addListener(textFieldFocusDidChange);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: <Widget>[
          Visibility(
            visible: widget.isCardNumberVisible,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              margin: const EdgeInsets.only(left: 16, top: 16, right: 16),
              child: TextFormField(
                key: widget.cardNumberKey,
                obscureText: widget.obscureNumber,
                controller: _cardNumberController,
                onChanged: _onCardNumberChange,
                onEditingComplete: () => FocusScope.of(context).requestFocus(expiryMonthNode),
                decoration: widget.inputConfiguration.cardNumberDecoration,
                style: widget.inputConfiguration.cardNumberTextStyle,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                autofillHints: widget.disableCardNumberAutoFillHints
                    ? null
                    : const <String>[AutofillHints.creditCardNumber],
                autovalidateMode: widget.autovalidateMode,
                validator: widget.cardNumberValidator ??
                    (String? value) => Validators.cardNumberValidator(
                          value,
                          widget.numberValidationMessage,
                        ),
              ),
            ),
          ),
          Visibility(visible: widget.isExpiryDateVisible || widget.enableCvv, child: const SizedBox(height: 8.0)),
          Row(
            children: <Widget>[
              Visibility(
                visible: widget.isExpiryDateVisible,
                child: Row(
                  children: <Widget>[
                    const SizedBox(width: 16.0),
                    SizedBox(
                      width: 150,
                      child: DropdownButtonFormField<String>(
                        key: widget.expiryMonthKey,
                        value: expiryMonth,
                        items: List<int>.generate(12, (int i) => i + 1)
                            .map((int i) => DropdownMenuItem<String>(
                                value: i.toString().padLeft(2, '0'),
                                alignment: AlignmentDirectional.center,
                                child: Text('${(i).toString().padLeft(2, '0')} - ${DateFormat.MMM().format(DateTime(0, i))}', textAlign: TextAlign.center)))
                            .toList(),
                        onChanged: _onExpiryMonthChange,
                        isExpanded: true,
                        hint: Text('Expiry Month', style: Theme.of(context).textTheme.labelLarge, textAlign: TextAlign.center),
                        focusNode: expiryMonthNode,
                        validator: widget.expiryMonthValidator ?? _validateExpiryMonth,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    const Text('/', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8.0),
                    SizedBox(
                      width: 150,
                      child: DropdownButtonFormField<String>(
                        key: widget.expiryYearKey,
                        value: expiryYear,
                        items: List<String>.generate(12, (int i) => DateFormat.y().format(DateTime(DateTime.now().year + i)))
                            .map((String y) => DropdownMenuItem<String>(
                                  value: y,
                                  alignment: AlignmentDirectional.center,
                                  child: Text(y),
                                ))
                            .toList(),
                        onChanged: _onExpiryYearChange,
                        isExpanded: true,
                        hint: Text('Expiry Year', style: Theme.of(context).textTheme.labelLarge, textAlign: TextAlign.center),
                        focusNode: expiryYearNode,
                        validator: widget.expiryYearValidator ?? _validateExpiryYear,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Visibility(
                  visible: widget.enableCvv,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    margin: const EdgeInsets.only(left: 16, right: 16),
                    child: TextFormField(
                      key: widget.cvvCodeKey,
                      obscureText: widget.obscureCvv,
                      focusNode: cvvFocusNode,
                      controller: _cvvCodeController,
                      onEditingComplete: _onCvvEditComplete,
                      decoration: widget.inputConfiguration.cvvCodeDecoration,
                      style: widget.inputConfiguration.cvvCodeTextStyle,
                      keyboardType: TextInputType.number,
                      autovalidateMode: widget.autovalidateMode,
                      textInputAction: widget.isHolderNameVisible
                          ? TextInputAction.next
                          : TextInputAction.done,
                      autofillHints: const <String>[
                        AutofillHints.creditCardSecurityCode
                      ],
                      onChanged: _onCvvChange,
                      validator: widget.cvvValidator ??
                          (String? value) => Validators.cvvValidator(
                                value,
                                widget.cvvValidationMessage,
                              ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Visibility(
            visible: widget.isHolderNameVisible,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              margin: const EdgeInsets.only(left: 16, top: 8, right: 16),
              child: TextFormField(
                key: widget.cardHolderKey,
                controller: _cardHolderNameController,
                onChanged: _onCardHolderNameChange,
                focusNode: cardHolderNode,
                decoration: widget.inputConfiguration.cardHolderDecoration,
                style: widget.inputConfiguration.cardHolderTextStyle,
                keyboardType: TextInputType.text,
                autovalidateMode: widget.autovalidateMode,
                textInputAction: TextInputAction.done,
                autofillHints: const <String>[AutofillHints.creditCardName],
                onEditingComplete: _onHolderNameEditComplete,
                textCapitalization: widget.isCardHolderNameUpperCase
                    ? TextCapitalization.characters
                    : TextCapitalization.none,
                inputFormatters: widget.isCardHolderNameUpperCase
                    ? const <TextInputFormatter>[UpperCaseTextFormatter()]
                    : null,
                validator: widget.cardHolderValidator,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cardHolderNode.dispose();
    cvvFocusNode.dispose();
    expiryMonthNode.dispose();
    expiryYearNode.dispose();
    _cardHolderNameController.dispose();
    _cardNumberController.dispose();
    _cvvCodeController.dispose();
    super.dispose();
  }

  void textFieldFocusDidChange() {
    isCvvFocused = creditCardModel.isCvvFocused = cvvFocusNode.hasFocus;
    onCreditCardModelChange(creditCardModel);
  }

  void createCreditCardModel() {
    cardNumber = widget.cardNumber;
    expiryMonth = widget.expiryMonth;
    expiryYear = widget.expiryYear;
    cardHolderName = widget.cardHolderName;
    cvvCode = widget.cvvCode;

    creditCardModel = CreditCardModel(
      cardNumber,
      expiryMonth ?? '',
      expiryYear ?? '',
      cardHolderName,
      cvvCode,
      isCvvFocused,
    );
  }

  String? _validateExpiryMonth(String? value) => Validators.expiryDateValidator(value, expiryYear, widget.dateValidationMessage);

  String? _validateExpiryYear(String? value) => Validators.expiryDateValidator(expiryMonth, value, widget.dateValidationMessage);

  void _onCardNumberChange(String value) {
    setState(() {
      creditCardModel.cardNumber = cardNumber = _cardNumberController.text;
      onCreditCardModelChange(creditCardModel);
    });
  }

  void _onExpiryMonthChange(String? value) {
    setState(() {
      creditCardModel.expiryMonth = expiryMonth = value!;
      onCreditCardModelChange(creditCardModel);
    });
  }

  void _onExpiryYearChange(String? value) {
    setState(() {
      creditCardModel.expiryYear = expiryYear = value!;
      onCreditCardModelChange(creditCardModel);
    });
  }

  void _onCvvChange(String text) {
    setState(() {
      creditCardModel.cvvCode = cvvCode = text;
      onCreditCardModelChange(creditCardModel);
    });
  }

  void _onCardHolderNameChange(String value) {
    setState(() {
      creditCardModel.cardHolderName =
          cardHolderName = _cardHolderNameController.text;
      onCreditCardModelChange(creditCardModel);
    });
  }

  void _onCvvEditComplete() {
    if (widget.isHolderNameVisible) {
      FocusScope.of(context).requestFocus(cardHolderNode);
    } else {
      FocusScope.of(context).unfocus();
      onCreditCardModelChange(creditCardModel);
      widget.onFormComplete?.call();
    }
  }

  void _onHolderNameEditComplete() {
    FocusScope.of(context).unfocus();
    onCreditCardModelChange(creditCardModel);
    widget.onFormComplete?.call();
  }
}
