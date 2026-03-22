import 'package:flutter/cupertino.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/models/woo_commerce/billing_address_model.dart';
import 'package:socialv/models/woo_commerce/cart_item_model.dart';
import 'package:socialv/models/woo_commerce/cart_model.dart';
import 'package:socialv/models/woo_commerce/country_model.dart';
import 'package:socialv/models/woo_commerce/order_model.dart';
import 'package:socialv/models/woo_commerce/payment_model.dart';
import 'package:socialv/models/woo_commerce/recently_viewed_products_model.dart';
import 'package:socialv/models/woo_commerce/related_products_model.dart';
import 'package:socialv/models/woo_commerce/wishlist_model.dart';
import '../models/woo_commerce/common_models.dart' hide ProductFilters;
import '../models/woo_commerce/category_model.dart';
import '../models/woo_commerce/common_models.dart';
import '../models/woo_commerce/product_list_model.dart';
import '../utils/constants.dart';

part 'shop_store.g.dart';

class ShopStore = ShopStoreBase with _$ShopStore;

abstract class ShopStoreBase with Store {
  /// common  vars
  @observable
  ObservableList<ProductListModel> productList = ObservableList<ProductListModel>();

  @observable
  ObservableList<CategoryModel> categoryList = ObservableList<CategoryModel>();

  @observable
  int selectedIndex = 0;

  @observable
  CategoryModel? selectedCategory;

  @observable
  int mPage = 1;

  @observable
  bool isLoading = false;

  @observable
  bool isError = false;

  @observable
  bool mIsLastPage = false;

  @observable
  String selectedShopSort = "";

  @observable
  FilterModel dropDownValue = FilterModel();

  @observable
  String selectedOrderBy = ProductFilters.date;

  @observable
  TextEditingController searchCont = TextEditingController();

  ///productCardComponentVars
  @observable
  String buttonName = "";

  @observable
  ObservableList cartItemIndexList = ObservableList();

  ///cartScreenVars
  @observable
  ObservableList<CartItemModel> cartItemList = ObservableList();

  @observable
  int total = 0;

  @observable
  CartModel? cart = CartModel();

  @observable
  int cartCount = getIntAsync(SharePreferencesKey.cartCount);

  @observable
  ObservableList<RelatedProductList> relatedProductList = ObservableList();

  @observable
  ObservableList<RecentlyViewedProductList> recentlyViewedProductList = ObservableList();

  ///ordersScreenVars
  @observable
  ObservableList<OrderModel> orderLists = ObservableList();

  @observable
  int orderIndex = 0;

  /// Product Details Screen
  @observable
  bool? isErrorProduct = false;

  @observable
  bool isFetched = false;

  @observable
  bool isLoadingProduct = false;

  @observable
  bool isWishListed = false;

  @observable
  PageController pageController = PageController();

  @observable
  ObservableList<GroupProductModel> groupProductList = ObservableList<GroupProductModel>();

  @observable
  int count = 1;

  ///  Wish list Screen
  @observable
  ObservableList<WishlistModel> orderList = ObservableList();



  /// Checkout screen vars

  @observable
  CartModel? cartCheckout;

  @observable
  bool isChange = false;

  @observable
  bool isPaymentGatewayLoading = true;

  @observable
  PaymentModel? selectedPaymentMethod;

  @observable
  ObservableList<PaymentModel> paymentGateways = ObservableList();

  @observable
  bool shippingTileExpanded = false;

  @observable
  BillingAddressModel billingAddress = BillingAddressModel();

  @observable
  BillingAddressModel shippingAddress = BillingAddressModel();

  @observable
  List<CountryModel> countriesList = [];

  /// edit shop details screen vars

  @observable
  bool isSameShippingAddress = false;

  @observable
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  ///Billing Address component Vars

  @observable
  CountryModel? selectedCountry;

  @observable
  StateModel? selectedState;

  /// cancel Order BottomSheet vars

  @observable
  String cancelOrderReason = "";

  @observable
  int cancelOrderIndex = 0;

  /// productReviewComponentVars

  @observable
  double rating = 0.0;

  @observable
  String orderStatus = "";

  @observable
  String selectedOption = "";

  @action
  Future<void> setLoading(bool val) async {
    isLoading=val;
  }

  Future<void> setCartCount(int value) async {
    cartCount = value;
    setValue(SharePreferencesKey.cartCount, value);
  }

}
