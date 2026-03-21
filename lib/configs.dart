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
const mTestAdMobBannerId = 'ca-app-pub-7933159179608841/2782073409';



/// STRIPE PAYMENT DETAIL
const STRIPE_MERCHANT_COUNTRY_CODE = 'MY';
const STRIPE_CURRENCY_CODE = 'MYR';
const STRIPE_TEST_PAYMENT_KEY = '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';
const STRIPE_TEST_PUBLISHABLE_KEY = 'pk_live_51I7IGpEvM09srKs7hW5T6yn2LltGHiCQ3QijHrYQB9IU08LantClVluFy8GLi1PjPMoW1KBo5BKeMJU8kVu02vn800koF8OQqm';

/// RAZORPAY PAYMENT DETAIL
const RAZORPAY_CURRENCY_CODE = 'INR';

const PAYPAL_CURRENCY_CODE = 'USD';

/// AGORA
const AGORA_APP_ID = '1a3c9ceab21f4c55b106d8ffb9ec5711';

///deeplink key
const DEEPLINK_KEY = "/socialv/"; // Add the Unique key from the shared URL

Country defaultCountry() {
  return Country(
    phoneCode: '60',
    countryCode: 'MY',
    e164Sc: 60,
    geographic: true,
    level: 1,
    name: 'Malaysia',
    example: '123456789',
    displayName: 'Malaysia (MY) [+60]',
    displayNameNoCountryCode: 'Malaysia (MY)',
    e164Key: '60-MY-0',
    fullExampleWithPlusSign: '+60123456789',
  );
}

// endregion
