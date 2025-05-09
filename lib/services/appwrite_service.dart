// TODO Implement this library.
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

class AppwriteService {
  final Client client =
      Client()
        ..setEndpoint('https://cloud.appwrite.io/v1')
        ..setProject('6812f68d003e629ec1fc');
  final Account account;

  AppwriteService()
    : account = Account(
        Client()
          ..setEndpoint('https://cloud.appwrite.io/v1')
          ..setProject('6812f68d003e629ec1fc'),
      );

  // ✅ Get User Data
  Future<User> getUser() async {
    return await account.get();
  }

  // ✅ Logout User
  Future<void> logout() async {
    await account.deleteSession(sessionId: 'current');
  }
}
