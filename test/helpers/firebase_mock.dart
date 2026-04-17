
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

class FirebaseMock {

  static MockFirebaseAuth getMockAuth() {

    final user = MockUser(
      uid: '12345',
      email: 'test@test.com',
      displayName: 'Test User',
    );

    final auth = MockFirebaseAuth(
      mockUser: user,
      signedIn: true,
    );

    return auth;
  }

}