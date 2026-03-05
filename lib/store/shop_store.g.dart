// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ShopStore on ShopStoreBase, Store {
  late final _$productListAtom =
      Atom(name: 'ShopStoreBase.productList', context: context);

  @override
  ObservableList<ProductListModel> get productList {
    _$productListAtom.reportRead();
    return super.productList;
  }

  @override
  set productList(ObservableList<ProductListModel> value) {
    _$productListAtom.reportWrite(value, super.productList, () {
      super.productList = value;
    });
  }

  late final _$categoryListAtom =
      Atom(name: 'ShopStoreBase.categoryList', context: context);

  @override
  ObservableList<CategoryModel> get categoryList {
    _$categoryListAtom.reportRead();
    return super.categoryList;
  }

  @override
  set categoryList(ObservableList<CategoryModel> value) {
    _$categoryListAtom.reportWrite(value, super.categoryList, () {
      super.categoryList = value;
    });
  }

  late final _$selectedIndexAtom =
      Atom(name: 'ShopStoreBase.selectedIndex', context: context);

  @override
  int get selectedIndex {
    _$selectedIndexAtom.reportRead();
    return super.selectedIndex;
  }

  @override
  set selectedIndex(int value) {
    _$selectedIndexAtom.reportWrite(value, super.selectedIndex, () {
      super.selectedIndex = value;
    });
  }

  late final _$selectedCategoryAtom =
      Atom(name: 'ShopStoreBase.selectedCategory', context: context);

  @override
  CategoryModel? get selectedCategory {
    _$selectedCategoryAtom.reportRead();
    return super.selectedCategory;
  }

  @override
  set selectedCategory(CategoryModel? value) {
    _$selectedCategoryAtom.reportWrite(value, super.selectedCategory, () {
      super.selectedCategory = value;
    });
  }

  late final _$mPageAtom = Atom(name: 'ShopStoreBase.mPage', context: context);

  @override
  int get mPage {
    _$mPageAtom.reportRead();
    return super.mPage;
  }

  @override
  set mPage(int value) {
    _$mPageAtom.reportWrite(value, super.mPage, () {
      super.mPage = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: 'ShopStoreBase.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$isErrorAtom =
      Atom(name: 'ShopStoreBase.isError', context: context);

  @override
  bool get isError {
    _$isErrorAtom.reportRead();
    return super.isError;
  }

  @override
  set isError(bool value) {
    _$isErrorAtom.reportWrite(value, super.isError, () {
      super.isError = value;
    });
  }

  late final _$mIsLastPageAtom =
      Atom(name: 'ShopStoreBase.mIsLastPage', context: context);

  @override
  bool get mIsLastPage {
    _$mIsLastPageAtom.reportRead();
    return super.mIsLastPage;
  }

  @override
  set mIsLastPage(bool value) {
    _$mIsLastPageAtom.reportWrite(value, super.mIsLastPage, () {
      super.mIsLastPage = value;
    });
  }

  late final _$selectedShopSortAtom =
      Atom(name: 'ShopStoreBase.selectedShopSort', context: context);

  @override
  String get selectedShopSort {
    _$selectedShopSortAtom.reportRead();
    return super.selectedShopSort;
  }

  @override
  set selectedShopSort(String value) {
    _$selectedShopSortAtom.reportWrite(value, super.selectedShopSort, () {
      super.selectedShopSort = value;
    });
  }

  late final _$dropDownValueAtom =
      Atom(name: 'ShopStoreBase.dropDownValue', context: context);

  @override
  FilterModel get dropDownValue {
    _$dropDownValueAtom.reportRead();
    return super.dropDownValue;
  }

  @override
  set dropDownValue(FilterModel value) {
    _$dropDownValueAtom.reportWrite(value, super.dropDownValue, () {
      super.dropDownValue = value;
    });
  }

  late final _$selectedOrderByAtom =
      Atom(name: 'ShopStoreBase.selectedOrderBy', context: context);

  @override
  String get selectedOrderBy {
    _$selectedOrderByAtom.reportRead();
    return super.selectedOrderBy;
  }

  @override
  set selectedOrderBy(String value) {
    _$selectedOrderByAtom.reportWrite(value, super.selectedOrderBy, () {
      super.selectedOrderBy = value;
    });
  }

  late final _$searchContAtom =
      Atom(name: 'ShopStoreBase.searchCont', context: context);

  @override
  TextEditingController get searchCont {
    _$searchContAtom.reportRead();
    return super.searchCont;
  }

  @override
  set searchCont(TextEditingController value) {
    _$searchContAtom.reportWrite(value, super.searchCont, () {
      super.searchCont = value;
    });
  }

  late final _$buttonNameAtom =
      Atom(name: 'ShopStoreBase.buttonName', context: context);

  @override
  String get buttonName {
    _$buttonNameAtom.reportRead();
    return super.buttonName;
  }

  @override
  set buttonName(String value) {
    _$buttonNameAtom.reportWrite(value, super.buttonName, () {
      super.buttonName = value;
    });
  }

  late final _$cartItemIndexListAtom =
      Atom(name: 'ShopStoreBase.cartItemIndexList', context: context);

  @override
  ObservableList<dynamic> get cartItemIndexList {
    _$cartItemIndexListAtom.reportRead();
    return super.cartItemIndexList;
  }

  @override
  set cartItemIndexList(ObservableList<dynamic> value) {
    _$cartItemIndexListAtom.reportWrite(value, super.cartItemIndexList, () {
      super.cartItemIndexList = value;
    });
  }

  late final _$cartItemListAtom =
      Atom(name: 'ShopStoreBase.cartItemList', context: context);

  @override
  ObservableList<CartItemModel> get cartItemList {
    _$cartItemListAtom.reportRead();
    return super.cartItemList;
  }

  @override
  set cartItemList(ObservableList<CartItemModel> value) {
    _$cartItemListAtom.reportWrite(value, super.cartItemList, () {
      super.cartItemList = value;
    });
  }

  late final _$totalAtom = Atom(name: 'ShopStoreBase.total', context: context);

  @override
  int get total {
    _$totalAtom.reportRead();
    return super.total;
  }

  @override
  set total(int value) {
    _$totalAtom.reportWrite(value, super.total, () {
      super.total = value;
    });
  }

  late final _$cartAtom = Atom(name: 'ShopStoreBase.cart', context: context);

  @override
  CartModel? get cart {
    _$cartAtom.reportRead();
    return super.cart;
  }

  @override
  set cart(CartModel? value) {
    _$cartAtom.reportWrite(value, super.cart, () {
      super.cart = value;
    });
  }

  late final _$cartCountAtom =
      Atom(name: 'ShopStoreBase.cartCount', context: context);

  @override
  int get cartCount {
    _$cartCountAtom.reportRead();
    return super.cartCount;
  }

  @override
  set cartCount(int value) {
    _$cartCountAtom.reportWrite(value, super.cartCount, () {
      super.cartCount = value;
    });
  }

  late final _$relatedProductListAtom =
      Atom(name: 'ShopStoreBase.relatedProductList', context: context);

  @override
  ObservableList<RelatedProductList> get relatedProductList {
    _$relatedProductListAtom.reportRead();
    return super.relatedProductList;
  }

  @override
  set relatedProductList(ObservableList<RelatedProductList> value) {
    _$relatedProductListAtom.reportWrite(value, super.relatedProductList, () {
      super.relatedProductList = value;
    });
  }

  late final _$recentlyViewedProductListAtom =
      Atom(name: 'ShopStoreBase.recentlyViewedProductList', context: context);

  @override
  ObservableList<RecentlyViewedProductList> get recentlyViewedProductList {
    _$recentlyViewedProductListAtom.reportRead();
    return super.recentlyViewedProductList;
  }

  @override
  set recentlyViewedProductList(
      ObservableList<RecentlyViewedProductList> value) {
    _$recentlyViewedProductListAtom
        .reportWrite(value, super.recentlyViewedProductList, () {
      super.recentlyViewedProductList = value;
    });
  }

  late final _$orderListsAtom =
      Atom(name: 'ShopStoreBase.orderLists', context: context);

  @override
  ObservableList<OrderModel> get orderLists {
    _$orderListsAtom.reportRead();
    return super.orderLists;
  }

  @override
  set orderLists(ObservableList<OrderModel> value) {
    _$orderListsAtom.reportWrite(value, super.orderLists, () {
      super.orderLists = value;
    });
  }

  late final _$orderIndexAtom =
      Atom(name: 'ShopStoreBase.orderIndex', context: context);

  @override
  int get orderIndex {
    _$orderIndexAtom.reportRead();
    return super.orderIndex;
  }

  @override
  set orderIndex(int value) {
    _$orderIndexAtom.reportWrite(value, super.orderIndex, () {
      super.orderIndex = value;
    });
  }

  late final _$isErrorProductAtom =
      Atom(name: 'ShopStoreBase.isErrorProduct', context: context);

  @override
  bool? get isErrorProduct {
    _$isErrorProductAtom.reportRead();
    return super.isErrorProduct;
  }

  @override
  set isErrorProduct(bool? value) {
    _$isErrorProductAtom.reportWrite(value, super.isErrorProduct, () {
      super.isErrorProduct = value;
    });
  }

  late final _$isFetchedAtom =
      Atom(name: 'ShopStoreBase.isFetched', context: context);

  @override
  bool get isFetched {
    _$isFetchedAtom.reportRead();
    return super.isFetched;
  }

  @override
  set isFetched(bool value) {
    _$isFetchedAtom.reportWrite(value, super.isFetched, () {
      super.isFetched = value;
    });
  }

  late final _$isLoadingProductAtom =
      Atom(name: 'ShopStoreBase.isLoadingProduct', context: context);

  @override
  bool get isLoadingProduct {
    _$isLoadingProductAtom.reportRead();
    return super.isLoadingProduct;
  }

  @override
  set isLoadingProduct(bool value) {
    _$isLoadingProductAtom.reportWrite(value, super.isLoadingProduct, () {
      super.isLoadingProduct = value;
    });
  }

  late final _$isWishListedAtom =
      Atom(name: 'ShopStoreBase.isWishListed', context: context);

  @override
  bool get isWishListed {
    _$isWishListedAtom.reportRead();
    return super.isWishListed;
  }

  @override
  set isWishListed(bool value) {
    _$isWishListedAtom.reportWrite(value, super.isWishListed, () {
      super.isWishListed = value;
    });
  }

  late final _$pageControllerAtom =
      Atom(name: 'ShopStoreBase.pageController', context: context);

  @override
  PageController get pageController {
    _$pageControllerAtom.reportRead();
    return super.pageController;
  }

  @override
  set pageController(PageController value) {
    _$pageControllerAtom.reportWrite(value, super.pageController, () {
      super.pageController = value;
    });
  }

  late final _$groupProductListAtom =
      Atom(name: 'ShopStoreBase.groupProductList', context: context);

  @override
  ObservableList<GroupProductModel> get groupProductList {
    _$groupProductListAtom.reportRead();
    return super.groupProductList;
  }

  @override
  set groupProductList(ObservableList<GroupProductModel> value) {
    _$groupProductListAtom.reportWrite(value, super.groupProductList, () {
      super.groupProductList = value;
    });
  }

  late final _$countAtom = Atom(name: 'ShopStoreBase.count', context: context);

  @override
  int get count {
    _$countAtom.reportRead();
    return super.count;
  }

  @override
  set count(int value) {
    _$countAtom.reportWrite(value, super.count, () {
      super.count = value;
    });
  }

  late final _$orderListAtom =
      Atom(name: 'ShopStoreBase.orderList', context: context);

  @override
  ObservableList<WishlistModel> get orderList {
    _$orderListAtom.reportRead();
    return super.orderList;
  }

  @override
  set orderList(ObservableList<WishlistModel> value) {
    _$orderListAtom.reportWrite(value, super.orderList, () {
      super.orderList = value;
    });
  }

  late final _$cartCheckoutAtom =
      Atom(name: 'ShopStoreBase.cartCheckout', context: context);

  @override
  CartModel? get cartCheckout {
    _$cartCheckoutAtom.reportRead();
    return super.cartCheckout;
  }

  @override
  set cartCheckout(CartModel? value) {
    _$cartCheckoutAtom.reportWrite(value, super.cartCheckout, () {
      super.cartCheckout = value;
    });
  }

  late final _$isChangeAtom =
      Atom(name: 'ShopStoreBase.isChange', context: context);

  @override
  bool get isChange {
    _$isChangeAtom.reportRead();
    return super.isChange;
  }

  @override
  set isChange(bool value) {
    _$isChangeAtom.reportWrite(value, super.isChange, () {
      super.isChange = value;
    });
  }

  late final _$isPaymentGatewayLoadingAtom =
      Atom(name: 'ShopStoreBase.isPaymentGatewayLoading', context: context);

  @override
  bool get isPaymentGatewayLoading {
    _$isPaymentGatewayLoadingAtom.reportRead();
    return super.isPaymentGatewayLoading;
  }

  @override
  set isPaymentGatewayLoading(bool value) {
    _$isPaymentGatewayLoadingAtom
        .reportWrite(value, super.isPaymentGatewayLoading, () {
      super.isPaymentGatewayLoading = value;
    });
  }

  late final _$selectedPaymentMethodAtom =
      Atom(name: 'ShopStoreBase.selectedPaymentMethod', context: context);

  @override
  PaymentModel? get selectedPaymentMethod {
    _$selectedPaymentMethodAtom.reportRead();
    return super.selectedPaymentMethod;
  }

  @override
  set selectedPaymentMethod(PaymentModel? value) {
    _$selectedPaymentMethodAtom.reportWrite(value, super.selectedPaymentMethod,
        () {
      super.selectedPaymentMethod = value;
    });
  }

  late final _$paymentGatewaysAtom =
      Atom(name: 'ShopStoreBase.paymentGateways', context: context);

  @override
  ObservableList<PaymentModel> get paymentGateways {
    _$paymentGatewaysAtom.reportRead();
    return super.paymentGateways;
  }

  @override
  set paymentGateways(ObservableList<PaymentModel> value) {
    _$paymentGatewaysAtom.reportWrite(value, super.paymentGateways, () {
      super.paymentGateways = value;
    });
  }

  late final _$shippingTileExpandedAtom =
      Atom(name: 'ShopStoreBase.shippingTileExpanded', context: context);

  @override
  bool get shippingTileExpanded {
    _$shippingTileExpandedAtom.reportRead();
    return super.shippingTileExpanded;
  }

  @override
  set shippingTileExpanded(bool value) {
    _$shippingTileExpandedAtom.reportWrite(value, super.shippingTileExpanded,
        () {
      super.shippingTileExpanded = value;
    });
  }

  late final _$billingAddressAtom =
      Atom(name: 'ShopStoreBase.billingAddress', context: context);

  @override
  BillingAddressModel get billingAddress {
    _$billingAddressAtom.reportRead();
    return super.billingAddress;
  }

  @override
  set billingAddress(BillingAddressModel value) {
    _$billingAddressAtom.reportWrite(value, super.billingAddress, () {
      super.billingAddress = value;
    });
  }

  late final _$shippingAddressAtom =
      Atom(name: 'ShopStoreBase.shippingAddress', context: context);

  @override
  BillingAddressModel get shippingAddress {
    _$shippingAddressAtom.reportRead();
    return super.shippingAddress;
  }

  @override
  set shippingAddress(BillingAddressModel value) {
    _$shippingAddressAtom.reportWrite(value, super.shippingAddress, () {
      super.shippingAddress = value;
    });
  }

  late final _$countriesListAtom =
      Atom(name: 'ShopStoreBase.countriesList', context: context);

  @override
  List<CountryModel> get countriesList {
    _$countriesListAtom.reportRead();
    return super.countriesList;
  }

  @override
  set countriesList(List<CountryModel> value) {
    _$countriesListAtom.reportWrite(value, super.countriesList, () {
      super.countriesList = value;
    });
  }

  late final _$isSameShippingAddressAtom =
      Atom(name: 'ShopStoreBase.isSameShippingAddress', context: context);

  @override
  bool get isSameShippingAddress {
    _$isSameShippingAddressAtom.reportRead();
    return super.isSameShippingAddress;
  }

  @override
  set isSameShippingAddress(bool value) {
    _$isSameShippingAddressAtom.reportWrite(value, super.isSameShippingAddress,
        () {
      super.isSameShippingAddress = value;
    });
  }

  late final _$formKeyAtom =
      Atom(name: 'ShopStoreBase.formKey', context: context);

  @override
  GlobalKey<FormState> get formKey {
    _$formKeyAtom.reportRead();
    return super.formKey;
  }

  @override
  set formKey(GlobalKey<FormState> value) {
    _$formKeyAtom.reportWrite(value, super.formKey, () {
      super.formKey = value;
    });
  }

  late final _$selectedCountryAtom =
      Atom(name: 'ShopStoreBase.selectedCountry', context: context);

  @override
  CountryModel? get selectedCountry {
    _$selectedCountryAtom.reportRead();
    return super.selectedCountry;
  }

  @override
  set selectedCountry(CountryModel? value) {
    _$selectedCountryAtom.reportWrite(value, super.selectedCountry, () {
      super.selectedCountry = value;
    });
  }

  late final _$selectedStateAtom =
      Atom(name: 'ShopStoreBase.selectedState', context: context);

  @override
  StateModel? get selectedState {
    _$selectedStateAtom.reportRead();
    return super.selectedState;
  }

  @override
  set selectedState(StateModel? value) {
    _$selectedStateAtom.reportWrite(value, super.selectedState, () {
      super.selectedState = value;
    });
  }

  late final _$cancelOrderReasonAtom =
      Atom(name: 'ShopStoreBase.cancelOrderReason', context: context);

  @override
  String get cancelOrderReason {
    _$cancelOrderReasonAtom.reportRead();
    return super.cancelOrderReason;
  }

  @override
  set cancelOrderReason(String value) {
    _$cancelOrderReasonAtom.reportWrite(value, super.cancelOrderReason, () {
      super.cancelOrderReason = value;
    });
  }

  late final _$cancelOrderIndexAtom =
      Atom(name: 'ShopStoreBase.cancelOrderIndex', context: context);

  @override
  int get cancelOrderIndex {
    _$cancelOrderIndexAtom.reportRead();
    return super.cancelOrderIndex;
  }

  @override
  set cancelOrderIndex(int value) {
    _$cancelOrderIndexAtom.reportWrite(value, super.cancelOrderIndex, () {
      super.cancelOrderIndex = value;
    });
  }

  late final _$ratingAtom =
      Atom(name: 'ShopStoreBase.rating', context: context);

  @override
  double get rating {
    _$ratingAtom.reportRead();
    return super.rating;
  }

  @override
  set rating(double value) {
    _$ratingAtom.reportWrite(value, super.rating, () {
      super.rating = value;
    });
  }

  late final _$orderStatusAtom =
      Atom(name: 'ShopStoreBase.orderStatus', context: context);

  @override
  String get orderStatus {
    _$orderStatusAtom.reportRead();
    return super.orderStatus;
  }

  @override
  set orderStatus(String value) {
    _$orderStatusAtom.reportWrite(value, super.orderStatus, () {
      super.orderStatus = value;
    });
  }

  late final _$selectedOptionAtom =
      Atom(name: 'ShopStoreBase.selectedOption', context: context);

  @override
  String get selectedOption {
    _$selectedOptionAtom.reportRead();
    return super.selectedOption;
  }

  @override
  set selectedOption(String value) {
    _$selectedOptionAtom.reportWrite(value, super.selectedOption, () {
      super.selectedOption = value;
    });
  }

  late final _$setLoadingAsyncAction =
      AsyncAction('ShopStoreBase.setLoading', context: context);

  @override
  Future<void> setLoading(bool val) {
    return _$setLoadingAsyncAction.run(() => super.setLoading(val));
  }

  @override
  String toString() {
    return '''
productList: ${productList},
categoryList: ${categoryList},
selectedIndex: ${selectedIndex},
selectedCategory: ${selectedCategory},
mPage: ${mPage},
isLoading: ${isLoading},
isError: ${isError},
mIsLastPage: ${mIsLastPage},
selectedShopSort: ${selectedShopSort},
dropDownValue: ${dropDownValue},
selectedOrderBy: ${selectedOrderBy},
searchCont: ${searchCont},
buttonName: ${buttonName},
cartItemIndexList: ${cartItemIndexList},
cartItemList: ${cartItemList},
total: ${total},
cart: ${cart},
cartCount: ${cartCount},
relatedProductList: ${relatedProductList},
recentlyViewedProductList: ${recentlyViewedProductList},
orderLists: ${orderLists},
orderIndex: ${orderIndex},
isErrorProduct: ${isErrorProduct},
isFetched: ${isFetched},
isLoadingProduct: ${isLoadingProduct},
isWishListed: ${isWishListed},
pageController: ${pageController},
groupProductList: ${groupProductList},
count: ${count},
orderList: ${orderList},
cartCheckout: ${cartCheckout},
isChange: ${isChange},
isPaymentGatewayLoading: ${isPaymentGatewayLoading},
selectedPaymentMethod: ${selectedPaymentMethod},
paymentGateways: ${paymentGateways},
shippingTileExpanded: ${shippingTileExpanded},
billingAddress: ${billingAddress},
shippingAddress: ${shippingAddress},
countriesList: ${countriesList},
isSameShippingAddress: ${isSameShippingAddress},
formKey: ${formKey},
selectedCountry: ${selectedCountry},
selectedState: ${selectedState},
cancelOrderReason: ${cancelOrderReason},
cancelOrderIndex: ${cancelOrderIndex},
rating: ${rating},
orderStatus: ${orderStatus},
selectedOption: ${selectedOption}
    ''';
  }
}
