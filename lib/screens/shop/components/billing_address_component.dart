import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main.dart';
import 'package:socialv/models/woo_commerce/billing_address_model.dart';
import 'package:socialv/models/woo_commerce/country_model.dart';
import 'package:socialv/store/shop_store.dart';
import 'package:socialv/utils/app_constants.dart';

class BillingAddressComponent extends StatefulWidget {
  final BillingAddressModel? data;
  final bool isBilling;
  final GlobalKey<FormState> formKey;

  const BillingAddressComponent({this.data, this.isBilling = false, required this.formKey});

  @override
  State<BillingAddressComponent> createState() => _BillingAddressComponentState();
}

class _BillingAddressComponentState extends State<BillingAddressComponent> {
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController company = TextEditingController();
  TextEditingController country = TextEditingController();
  TextEditingController addOne = TextEditingController();
  TextEditingController addTwo = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController postCode = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController email = TextEditingController();

  FocusNode firstNameFocus = FocusNode();
  FocusNode lastNameFocus = FocusNode();
  FocusNode companyFocus = FocusNode();
  FocusNode addOneFocus = FocusNode();
  FocusNode addTwoFocus = FocusNode();
  FocusNode cityFocus = FocusNode();
  FocusNode postCodeFocus = FocusNode();
  FocusNode phoneFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode stateFocus = FocusNode();

  ShopStore billingAddressVars = ShopStore();

  void init() {
    firstName.text = widget.data!.firstName.validate();
    lastName.text = widget.data!.lastName.validate();
    company.text = widget.data!.company.validate();
    country.text = widget.data!.country.validate();
    addOne.text = widget.data!.address_1.validate();
    addTwo.text = widget.data!.address_2.validate();
    city.text = widget.data!.city.validate();
    state.text = widget.data!.state.validate();
    postCode.text = widget.data!.postcode.validate();
    phone.text = widget.data!.phone.validate();
    email.text = widget.data!.email.validate();

    if (widget.data!.country.validate().isNotEmpty) {
      if (shopStore.countriesList.any((element) => element.name == widget.data!.country.validate())) {
        billingAddressVars.selectedCountry = shopStore.countriesList.firstWhere((element) => element.name == widget.data!.country.validate());
      }
      if (billingAddressVars.selectedCountry != null && billingAddressVars.selectedCountry!.states != null) {
        if (widget.data!.state.validate().isNotEmpty) {
          if (billingAddressVars.selectedCountry!.states.validate().any((element) => element.name == widget.data!.state.validate()))
            billingAddressVars.selectedState = billingAddressVars.selectedCountry!.states.validate().firstWhere((element) => element.name == widget.data!.state.validate());
        }
      }
    } else {
      billingAddressVars.selectedCountry = null;
      billingAddressVars.selectedState = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    init();
    return Observer(builder: (context) {
      return Form(
        key: widget.formKey,
        child: Column(
          children: [
            16.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: context.width() / 2 - 20,
                  decoration: BoxDecoration(color: context.scaffoldBackgroundColor, borderRadius: radius(defaultAppButtonRadius)),
                  child: AppTextField(
                    focus: firstNameFocus,
                    nextFocus: lastNameFocus,
                    enabled: !appStore.isLoading,
                    controller: firstName,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    textFieldType: TextFieldType.NAME,
                    textStyle: primaryTextStyle(),
                    maxLines: 1,
                    decoration: inputDecorationFilled(context, label: language.firstName, fillColor: context.scaffoldBackgroundColor),
                    onChanged: (text) {
                      if (widget.isBilling) {
                        shopStore.billingAddress.firstName = text;
                      } else {
                        shopStore.shippingAddress.firstName = text;
                      }
                    },
                    onFieldSubmitted: (text) {
                      if (widget.isBilling) {
                        shopStore.billingAddress.firstName = text;
                      } else {
                        shopStore.shippingAddress.firstName = text;
                      }
                    },
                  ),
                ),
                Container(
                  width: context.width() / 2 - 20,
                  decoration: BoxDecoration(color: context.scaffoldBackgroundColor, borderRadius: radius(defaultAppButtonRadius)),
                  child: AppTextField(
                    focus: lastNameFocus,
                    nextFocus: companyFocus,
                    enabled: !appStore.isLoading,
                    controller: lastName,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    textFieldType: TextFieldType.NAME,
                    textStyle: primaryTextStyle(),
                    maxLines: 1,
                    decoration: inputDecorationFilled(context, label: language.lastName, fillColor: context.scaffoldBackgroundColor),
                    onChanged: (text) {
                      if (widget.isBilling) {
                        shopStore.billingAddress.lastName = text;
                      } else {
                        shopStore.shippingAddress.lastName = text;
                      }
                    },
                    onFieldSubmitted: (text) {
                      if (widget.isBilling) {
                        shopStore.billingAddress.lastName = text;
                      } else {
                        shopStore.shippingAddress.lastName = text;
                      }
                    },
                  ),
                ),
              ],
            ),
            16.height,
            Container(
              decoration: BoxDecoration(color: context.scaffoldBackgroundColor, borderRadius: radius(defaultAppButtonRadius)),
              child: AppTextField(
                isValidationRequired: false,
                enabled: !appStore.isLoading,
                controller: company,
                focus: companyFocus,
                nextFocus: addOneFocus,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                textFieldType: TextFieldType.NAME,
                textStyle: primaryTextStyle(),
                maxLines: 1,
                decoration: inputDecorationFilled(context, label: language.company, fillColor: context.scaffoldBackgroundColor),
                onChanged: (text) {
                  if (widget.isBilling) {
                    shopStore.billingAddress.company = text;
                  } else {
                    shopStore.shippingAddress.company = text;
                  }
                },
                onFieldSubmitted: (text) {
                  if (widget.isBilling) {
                    shopStore.billingAddress.company = text;
                  } else {
                    shopStore.shippingAddress.company = text;
                  }
                },
              ),
            ),
            16.height,
            Container(
              decoration: BoxDecoration(color: context.scaffoldBackgroundColor, borderRadius: radius(defaultAppButtonRadius)),
              child: AppTextField(
                enabled: !appStore.isLoading,
                controller: addOne,
                focus: addOneFocus,
                nextFocus: addTwoFocus,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                textFieldType: TextFieldType.NAME,
                textStyle: primaryTextStyle(),
                maxLines: 1,
                decoration: inputDecorationFilled(context, label: '${language.address} 1', fillColor: context.scaffoldBackgroundColor),
                onChanged: (text) {
                  if (widget.isBilling) {
                    shopStore.billingAddress.address_1 = text;
                  } else {
                    shopStore.shippingAddress.address_1 = text;
                  }
                },
                onFieldSubmitted: (text) {
                  if (widget.isBilling) {
                    shopStore.billingAddress.address_1 = text;
                  } else {
                    shopStore.shippingAddress.address_1 = text;
                  }
                },
              ),
            ),
            16.height,
            Container(
              decoration: BoxDecoration(color: context.scaffoldBackgroundColor, borderRadius: radius(defaultAppButtonRadius)),
              child: AppTextField(
                isValidationRequired: false,
                enabled: !appStore.isLoading,
                controller: addTwo,
                focus: addTwoFocus,
                nextFocus: cityFocus,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                textFieldType: TextFieldType.NAME,
                textStyle: primaryTextStyle(),
                maxLines: 1,
                decoration: inputDecorationFilled(context, label: '${language.address} 2', fillColor: context.scaffoldBackgroundColor),
                onChanged: (text) {
                  if (widget.isBilling) {
                    shopStore.billingAddress.address_2 = text;
                  } else {
                    shopStore.shippingAddress.address_2 = text;
                  }
                },
                onFieldSubmitted: (text) {
                  if (widget.isBilling) {
                    shopStore.billingAddress.address_2 = text;
                  } else {
                    shopStore.shippingAddress.address_2 = text;
                  }
                },
              ),
            ),
            16.height,
            Observer(builder: (context) {
              return DropdownButtonFormField(
                menuMaxHeight: context.height() / 2,
                borderRadius: BorderRadius.circular(commonRadius),
                icon: Icon(Icons.arrow_drop_down, color: appStore.isDarkMode ? bodyDark : bodyWhite),
                elevation: 8,
                isExpanded: true,
                style: primaryTextStyle(),
                decoration: inputDecorationFilled(
                  context,
                  label: language.country,
                  fillColor: context.scaffoldBackgroundColor,
                ),
                onChanged: (CountryModel? newValue) {
                  billingAddressVars.selectedCountry = newValue!;
                  if (widget.isBilling) {
                    shopStore.billingAddress.country = newValue.name;
                  } else {
                    shopStore.shippingAddress.country = newValue.name;
                  }
                  billingAddressVars.selectedState = null;
                  state.clear();
                },
                hint: Text(language.country, style: secondaryTextStyle(weight: FontWeight.w600)),
                items: shopStore.countriesList.validate().map<DropdownMenuItem<CountryModel>>((CountryModel value) {
                  return DropdownMenuItem<CountryModel>(
                    value: value,
                    child: Text(value.name.validate(), style: primaryTextStyle(), overflow: TextOverflow.ellipsis, maxLines: 1),
                  );
                }).toList(),
                initialValue: billingAddressVars.selectedCountry,
              );
            }),
            16.height,
            Observer(builder: (context) {
              return billingAddressVars.selectedCountry != null && billingAddressVars.selectedCountry!.states.validate().isNotEmpty
                  ? DropdownButtonFormField(
                      decoration: inputDecorationFilled(
                        context,
                        label: language.state,
                        fillColor: context.scaffoldBackgroundColor,
                      ),
                      style: primaryTextStyle(),
                      initialValue: billingAddressVars.selectedState,
                      borderRadius: BorderRadius.circular(commonRadius),
                      icon: Icon(Icons.arrow_drop_down, color: appStore.isDarkMode ? bodyDark : bodyWhite),
                      elevation: 8,
                      isExpanded: true,
                      onTap: () {
                        if (billingAddressVars.selectedCountry == null) toast(language.pleaseSelectCountry);
                      },
                      onChanged: (text) {
                        if (widget.isBilling) {
                          shopStore.billingAddress.state = text?.name;
                        } else {
                          shopStore.shippingAddress.state = text?.name;
                        }
                      },
                      hint: Text(language.state, style: secondaryTextStyle(weight: FontWeight.w600)),
                      items: billingAddressVars.selectedCountry?.states
                          .validate()
                          .map<DropdownMenuItem<StateModel>>(
                            (state) => DropdownMenuItem<StateModel>(
                              value: state,
                              child: Text(
                                state.name.validate(),
                                style: primaryTextStyle(),
                              ).paddingSymmetric(horizontal: 0),
                              onTap: () {
                                billingAddressVars.selectedState = state;
                              },
                            ),
                          )
                          .toList(),
                    )
                  : Container(
                      decoration: BoxDecoration(color: context.scaffoldBackgroundColor, borderRadius: radius(defaultAppButtonRadius)),
                      child: AppTextField(
                        controller: state,
                        focus: stateFocus,
                        nextFocus: cityFocus,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        textFieldType: TextFieldType.NAME,
                        textStyle: primaryTextStyle(),
                        maxLines: 1,
                        decoration: inputDecorationFilled(context, label: language.state, fillColor: context.scaffoldBackgroundColor),
                        onTap: () {
                          if (billingAddressVars.selectedCountry == null) toast(language.pleaseSelectCountry);
                        },
                        onChanged: (text) {
                          if (widget.isBilling) {
                            shopStore.billingAddress.state = text;
                          } else {
                            shopStore.shippingAddress.state = text;
                          }
                        },
                        onFieldSubmitted: (text) {
                          if (widget.isBilling) {
                            shopStore.billingAddress.state = text;
                          } else {
                            shopStore.shippingAddress.state = text;
                          }
                        },
                      ),
                    );
            }),
            16.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: context.width() / 2 - 20,
                  decoration: BoxDecoration(color: context.scaffoldBackgroundColor, borderRadius: radius(defaultAppButtonRadius)),
                  child: AppTextField(
                    enabled: !appStore.isLoading,
                    controller: city,
                    focus: cityFocus,
                    nextFocus: postCodeFocus,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    textFieldType: TextFieldType.NAME,
                    textStyle: primaryTextStyle(),
                    maxLines: 1,
                    decoration: inputDecorationFilled(context, label: language.city, fillColor: context.scaffoldBackgroundColor),
                    onChanged: (text) {
                      if (widget.isBilling) {
                        shopStore.billingAddress.city = text;
                      } else {
                        shopStore.shippingAddress.city = text;
                      }
                    },
                    onFieldSubmitted: (text) {
                      if (widget.isBilling) {
                        shopStore.billingAddress.city = text;
                      } else {
                        shopStore.shippingAddress.city = text;
                      }
                    },
                  ),
                ),
                Container(
                  width: context.width() / 2 - 20,
                  decoration: BoxDecoration(color: context.scaffoldBackgroundColor, borderRadius: radius(defaultAppButtonRadius)),
                  child: AppTextField(
                    enabled: !appStore.isLoading,
                    controller: postCode,
                    focus: postCodeFocus,
                    nextFocus: phoneFocus,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    textFieldType: TextFieldType.NUMBER,
                    textStyle: primaryTextStyle(),
                    maxLines: 1,
                    decoration: inputDecorationFilled(context, label: language.postCode, fillColor: context.scaffoldBackgroundColor),
                    onChanged: (text) {
                      if (widget.isBilling) {
                        shopStore.billingAddress.postcode = text;
                      } else {
                        shopStore.shippingAddress.postcode = text;
                      }
                    },
                    onFieldSubmitted: (text) {
                      if (widget.isBilling) {
                        shopStore.billingAddress.postcode = text;
                      } else {
                        shopStore.shippingAddress.postcode = text;
                      }
                    },
                  ),
                ),
              ],
            ),
            16.height,
            Container(
              decoration: BoxDecoration(color: context.scaffoldBackgroundColor, borderRadius: radius(defaultAppButtonRadius)),
              child: AppTextField(
                enabled: !appStore.isLoading,
                controller: phone,
                focus: phoneFocus,
                readOnly: false,
                nextFocus: emailFocus,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                textFieldType: TextFieldType.PHONE,
                textStyle: primaryTextStyle(),
                maxLines: 1,
                decoration: inputDecorationFilled(context, label: language.phone, fillColor: context.scaffoldBackgroundColor),
                onChanged: (text) {
                  if (widget.isBilling) {
                    shopStore.billingAddress.phone = text;
                  } else {
                    shopStore.shippingAddress.phone = text;
                  }
                },
                onFieldSubmitted: (text) {
                  if (widget.isBilling) {
                    shopStore.billingAddress.phone = text;
                  } else {
                    shopStore.shippingAddress.phone = text;
                  }
                },
              ),
            ),
            16.height,
            Container(
              decoration: BoxDecoration(color: context.scaffoldBackgroundColor, borderRadius: radius(defaultAppButtonRadius)),
              child: AppTextField(
                enabled: !appStore.isLoading,
                controller: email,
                focus: emailFocus,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                textFieldType: TextFieldType.EMAIL,
                textStyle: primaryTextStyle(),
                maxLines: 1,
                decoration: inputDecorationFilled(context, label: language.email, fillColor: context.scaffoldBackgroundColor),
                onChanged: (text) {
                  if (widget.isBilling) {
                    shopStore.billingAddress.email = text;
                  } else {
                    shopStore.shippingAddress.email = text;
                  }
                },
                onFieldSubmitted: (text) {
                  if (widget.isBilling) {
                    shopStore.billingAddress.email = text;
                  } else {
                    shopStore.shippingAddress.email = text;
                  }
                },
              ),
            ).visible(widget.isBilling),
            16.height,
          ],
        ),
      );
    });
  }
}
