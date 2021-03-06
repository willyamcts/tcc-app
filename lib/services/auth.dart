import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tcc/utils/logger.dart';

class AuthService {
  static final AuthService _authService = AuthService._internal();
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  String _verificationId;

  static FirebaseUser user;
  static Stream<FirebaseUser> userStream;

  final FirebaseAnalytics _analytics = FirebaseAnalytics();

  factory AuthService.singleton() {
    _firebaseAuth.setLanguageCode('pt-BR');

    userStream = _firebaseAuth.onAuthStateChanged;

    _firebaseAuth.onAuthStateChanged.listen((FirebaseUser firebaseUser) {
      user = firebaseUser;
    });

    return _authService;
  }

  AuthService._internal();

  Future<FirebaseUser> currentUser() async {
    try {
      return (await _firebaseAuth.currentUser());
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<bool> confirmPhone(smsCode) async {
    try {
      AuthCredential phoneAuthCredential = PhoneAuthProvider.getCredential(
          verificationId: _verificationId, smsCode: smsCode);

      await user.updatePhoneNumberCredential(phoneAuthCredential);

      await _analytics.logLogin(loginMethod: 'phone-verified');

      _verificationId = null;

      return true;
    } catch (error) {
      print(error);

      return false;
    }
  }

  Future<bool> verifyPhone(phoneNumber) async {
    phoneNumber = '+55$phoneNumber';

    try {
      await _firebaseAuth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          timeout: Duration(seconds: 60),
          // int forceResendingToken,
          verificationCompleted: (AuthCredential authCredential) {
            print('verificationCompleted');
          },
          verificationFailed: (AuthException authException) {
            print('verificationFailed');
            print(authException.code);
            print(authException.message);
          },
          codeSent: (String codeSent, [int number]) {
            print('codeSent');
            _verificationId = codeSent;
          },
          codeAutoRetrievalTimeout: (String timeout) {
            print('timeout');
            _verificationId = timeout;
          });

      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  Future<bool> googleSignIn() async {
    try {
      final GoogleSignInAccount googleSignInAccount =
          await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential authCredential = GoogleAuthProvider.getCredential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken);

      await _firebaseAuth.signInWithCredential(authCredential);

      await _analytics.logLogin(loginMethod: 'google-signin');

      return true;
    } catch (error) {
      print(error);
      Logger.errorEvent(error);
      return false;
    }
  }

  Future<void> googleSignOut() async {
    await _analytics.logLogin(loginMethod: 'firebase-signout');
    await _firebaseAuth.signOut();

    // if(Platform.isIOS) return;

    await _analytics.logLogin(loginMethod: 'google-signout');
    await _googleSignIn.signOut();
  }
}
