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

const DOMAIN_URL = "";

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
const mAdMobAppId = 'Please put your AdMob App ID here';
const mAdMobBannerId = 'Please put your AdMob Banner ID here';

// iOS
const mAdMobAppIdIOS = 'Please put your AdMob App ID here';
const mAdMobBannerIdIOS = 'Please put your AdMob Banner ID here';

//Todo : Always add this test key to manifest file after update
const mTestAdMobBannerId = 'Please put your AdMob Test Banner ID here';



/// STRIPE PAYMENT DETAIL
const STRIPE_MERCHANT_COUNTRY_CODE = 'IN';
const STRIPE_CURRENCY_CODE = 'INR';
const STRIPE_TEST_PAYMENT_KEY = 'Please put your Stripe Secret Key here';
const STRIPE_TEST_PUBLISHABLE_KEY = 'Please put your Stripe Publishable Key here';

/// RAZORPAY PAYMENT DETAIL
const RAZORPAY_CURRENCY_CODE = 'INR';

const PAYPAL_CURRENCY_CODE = 'USD';

/// AGORA
const AGORA_APP_ID = 'Please put your Agora App ID here';

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
