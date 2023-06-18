import 'package:firebase_database/firebase_database.dart';

final DatabaseReference emailWhitelistRef =
    FirebaseDatabase.instance.ref().child('EmailWhitelist');

// Add an email to the whitelist
void addEmailToWhitelist(String email) {
  emailWhitelistRef.push().set({
    'email': email,
  });
}

// Get the email whitelist
Future<List<String>> getEmailWhitelist() async {
  List<String> emailList = [];

  DatabaseEvent event = await emailWhitelistRef.once();
  DataSnapshot dataSnapshot = event.snapshot;
  final data = dataSnapshot.value as Map<dynamic, dynamic>;

  data.forEach((key, value) {
    emailList.add(value['email']);
  });

  return emailList;
}

// Remove an email from the whitelist
Future<void> removeEmailFromWhitelist(String email) async {
  DatabaseEvent event = await emailWhitelistRef.once();
  DataSnapshot dataSnapshot = event.snapshot;
  final data = dataSnapshot.value as Map<dynamic, dynamic>;

  data.forEach((key, value) {
    if (value['email'] == email) {
      emailWhitelistRef.child(key).remove();
    }
  });
}
bool checkEmailInWhitelist(String email, List<String> whitelist) {
  return whitelist.contains(email);
}

