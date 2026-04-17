import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import '../helpers/firebase_mock.dart';

void main() {

  late MockFirebaseAuth mockAuth;

  setUp(() {
    mockAuth = FirebaseMock.getMockAuth();
  });

  test("Login user success", () async {

    final result = await mockAuth.signInWithEmailAndPassword(
      email: "test@test.com",
      password: "123456",
    );

    expect(result.user, isNotNull);
    expect(result.user!.email, "test@test.com");

  });

}