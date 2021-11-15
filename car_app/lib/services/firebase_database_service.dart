import 'package:firebase_database/firebase_database.dart';

class FirebaseDatabaseService {
  static final DatabaseReference reference = FirebaseDatabase(
          databaseURL:
              'https://carapp-313506-default-rtdb.asia-southeast1.firebasedatabase.app/')
      .reference();

  static Stream<DataSnapshot?>? getDriverPosition(int? id) {
    if (id != null)
    return reference.child('driver/$id').get().catchError((error) {
      print('Can not get driver location');
    }).asStream();
  }
}
