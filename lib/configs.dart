import 'package:country_picker/country_picker.dart';

/// App Name
const APP_NAME = "SocialV";

/// App Icon src
const APP_ICON = "assets/app_icon.png";

/// Splash screen image src
const SPLASH_SCREEN_IMAGE = 'assets/images/splash_image.png';

/// NOTE: Do not add slash (/) or (https://) or (http://) at the end of your domain.
const WEB_SOCKET_DOMAIN = "apps.iqonic.design";

/// NOTE: Do not add slash (/) at the end of your domain.

/// live Domain URL

const DOMAIN_URL = "https://dna63.com";

///Testing Domain URL

const BASE_URL = '$DOMAIN_URL/wp-json/';

/// AppStore Url
const IOS_APP_LINK = 'https://apps.apple.com/us/app/socialv/id1641646237';

/// Terms and Conditions URL
const TERMS_AND_CONDITIONS_URL = '$DOMAIN_URL/terms-condition/';

/// Privacy Policy URL
const PRIVACY_POLICY_URL = '$DOMAIN_URL/privacy-policy-2/';

/// Support URL
const SUPPORT_URL = 'https://iqonic.desky.support';

/// AdMod Id
// Android
const mAdMobAppId = 'ca-app-pub-7933159179608841~5518394874';
const mAdMobBannerId = 'ca-app-pub-7933159179608841/2782073409';

// iOS
const mAdMobAppIdIOS = 'ca-app-pub-7933159179608841~4803587733';
const mAdMobBannerIdIOS = 'ca-app-pub-7933159179608841/2470076897';

//Todo : Always add this test key to manifest file after update
const mTestAdMobBannerId = 'Please add your AdMob Test Banner ID here';



/// STRIPE PAYMENT DETAIL
const STRIPE_MERCHANT_COUNTRY_CODE = 'MY';
const STRIPE_CURRENCY_CODE = 'MYR';
const STRIPE_TEST_PAYMENT_KEY = String.fromEnvironment('STRIPE_SECRET_KEY', defaultValue: 'sk_test_your_key_here');
const STRIPE_TEST_PUBLISHABLE_KEY = String.fromEnvironment('STRIPE_PUBLISHABLE_KEY', defaultValue: 'pk_test_your_key_here');

/// RAZORPAY PAYMENT DETAIL
const RAZORPAY_CURRENCY_CODE = 'INR';

const PAYPAL_CURRENCY_CODE = 'USD';

/// AGORA
const AGORA_APP_ID = '1a3c9ceab21f4c55b106d8ffb9ec5711';

///deeplink key
const DEEPLINK_KEY = "/socialv/"; // Add the Unique key from the shared URL

Country defaultCountry() {
  return Country(
    phoneCode: '91',
    countryCode: 'IN',
    e164Sc: 91,
    geographic: true,
    level: 1,
    name: 'India',
    example: '9123456789',
    displayName: 'India (IN) [+91]',
    displayNameNoCountryCode: 'India (IN)',
    e164Key: '91-IN-0',
    fullExampleWithPlusSign: '+919123456789',
  );
}

// endregion
