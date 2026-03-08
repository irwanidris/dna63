// This is the updated reGenerateToken function content
Future<void> reGenerateToken() async {
  log('Regenerating Token - attempting silent re-login...');
  
  // NOTE: JWT /token/refresh endpoint removed because it requires cookie-based
  // refresh tokens that Flutter HTTP client cannot easily handle.
  // Instead, we use silent re-login with securely stored credentials.
  
  // Attempt silent re-login if we have stored credentials
  if (userStore.loginEmail.isNotEmpty && userStore.password.isNotEmpty) {
    Map request = {
      Users.username: userStore.loginEmail,
      Users.password: userStore.password,
    };
    
    return await loginUser(request: request, isSocialLogin: appStore.isSocialLogin).then((value) async {
      log('Token regenerated via silent re-login successfully');
      // New token is automatically stored by loginUser() via userStore.setToken()
    }).catchError((e) {
      // Silent re-login failed - user must login again
      log('Silent re-login failed: ${e.toString()}');
      userStore.setToken('');
      appStore.setLoggedIn(false);
      throw 'Session expired. Please login again.';
    });
  } else {
    // No stored credentials available - user must login again
    log('No credentials available for silent re-login');
    userStore.setToken('');
    appStore.setLoggedIn(false);
    throw 'Session expired. Please login again.';
  }
}
