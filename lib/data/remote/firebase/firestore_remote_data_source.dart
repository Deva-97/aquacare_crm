import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_constants.dart';

class FirestoreRemoteDataSource {
  FirestoreRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> collection(String path) {
    return _firestore.collection(path);
  }

  Future<Map<String, dynamic>?> getUser(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await collection(AppConstants.usersCollection).doc(uid).get();
    if (!snapshot.exists) {
      return null;
    }
    return _normalizeMap(snapshot.data() ?? <String, dynamic>{});
  }

  Stream<Map<String, dynamic>?> watchUser(String uid) {
    return collection(AppConstants.usersCollection).doc(uid).snapshots().map(
      (DocumentSnapshot<Map<String, dynamic>> snapshot) {
        if (!snapshot.exists) {
          return null;
        }
        return _normalizeMap(snapshot.data() ?? <String, dynamic>{});
      },
    );
  }

  Future<void> setUser(String uid, Map<String, dynamic> data) {
    return collection(AppConstants.usersCollection).doc(uid).set(data, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await collection(AppConstants.usersCollection).orderBy('createdAt').get();
    return snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => _normalizeMap(doc.data()))
        .toList();
  }

  Stream<List<Map<String, dynamic>>> watchPendingUsers() {
    return collection(AppConstants.usersCollection)
        .where('status', isEqualTo: AppConstants.pendingStatus)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
      return snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => _normalizeMap(doc.data()))
          .toList();
    });
  }

  Future<bool> claimInitialOwner(String uid) async {
    final DocumentReference<Map<String, dynamic>> bootstrapRef = _firestore
        .collection(AppConstants.systemCollection)
        .doc(AppConstants.bootstrapDocument);

    return _firestore.runTransaction<bool>((Transaction transaction) async {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await transaction.get(bootstrapRef);
      if (snapshot.exists) {
        return false;
      }
      transaction.set(bootstrapRef, <String, dynamic>{
        'ownerUid': uid,
        'claimedAt': DateTime.now().toIso8601String(),
      });
      return true;
    });
  }

  Future<List<Map<String, dynamic>>> fetchCollection(String path) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await collection(path).get(const GetOptions(source: Source.server));
    return snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
            <String, dynamic>{..._normalizeMap(doc.data()), 'id': doc.id})
        .toList();
  }

  Future<Map<String, dynamic>?> fetchDocument(String path, String documentId) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await collection(path).doc(documentId).get(const GetOptions(source: Source.server));
    if (!snapshot.exists) {
      return null;
    }
    return <String, dynamic>{..._normalizeMap(snapshot.data() ?? <String, dynamic>{}), 'id': documentId};
  }

  Future<List<Map<String, dynamic>>> fetchWhereEquals({
    required String path,
    required String field,
    required Object? value,
  }) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await collection(path).where(field, isEqualTo: value).get(const GetOptions(source: Source.server));
    return snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
            <String, dynamic>{..._normalizeMap(doc.data()), 'id': doc.id})
        .toList();
  }

  Future<List<Map<String, dynamic>>> fetchWhereIn({
    required String path,
    required String field,
    required List<String> values,
  }) async {
    if (values.isEmpty) {
      return <Map<String, dynamic>>[];
    }
    final List<Map<String, dynamic>> merged = <Map<String, dynamic>>[];
    for (int index = 0; index < values.length; index += 10) {
      final List<String> chunk = values.sublist(
        index,
        index + 10 > values.length ? values.length : index + 10,
      );
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await collection(path).where(field, whereIn: chunk).get(const GetOptions(source: Source.server));
      merged.addAll(
        snapshot.docs.map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              <String, dynamic>{..._normalizeMap(doc.data()), 'id': doc.id},
        ),
      );
    }
    return merged;
  }

  Future<void> upsertDocument(
    String path,
    String documentId,
    Map<String, dynamic> data,
  ) {
    return collection(path).doc(documentId).set(data, SetOptions(merge: true));
  }

  Future<void> deleteDocument(String path, String documentId) {
    return collection(path).doc(documentId).delete();
  }

  Future<List<String>> fetchCities() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await collection(AppConstants.citiesCollection).orderBy('name').get();
    return snapshot.docs
        .map((doc) => doc.data()['name'] as String? ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }

  Future<void> saveCity(String cityName) {
    final String normalized = cityName.trim();
    if (normalized.isEmpty) return Future.value();
    final String docId = normalized.toLowerCase().replaceAll(' ', '_');
    return collection(AppConstants.citiesCollection)
        .doc(docId)
        .set(<String, dynamic>{'name': normalized}, SetOptions(merge: true));
  }

  Future<void> deleteCity(String cityName) {
    final String docId = cityName.trim().toLowerCase().replaceAll(' ', '_');
    return collection(AppConstants.citiesCollection).doc(docId).delete();
  }

  Map<String, dynamic> _normalizeMap(Map<String, dynamic> value) {
    return value.map((String key, dynamic item) {
      if (item is Timestamp) {
        return MapEntry<String, dynamic>(key, item.toDate().toIso8601String());
      }
      return MapEntry<String, dynamic>(key, item);
    });
  }
}
