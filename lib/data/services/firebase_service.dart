import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  FirebaseService({required this.firestore, required this.auth});

  // Get current authenticated user
  User? getCurrentUser() => auth.currentUser;

  // Real-time user stream
  Stream<DocumentSnapshot> getUserStream(String userId) =>
      firestore.collection('users').doc(userId).snapshots();

  // Real-time transactions stream
  Stream<QuerySnapshot> getTransactionsStream(String userId) => firestore
      .collection('transactions')
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots();

  // Batch write operation
  Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    final batch = firestore.batch();
    for (var op in operations) {
      final docRef = firestore.collection(op['collection']).doc(op['docId']);
      if (op['type'] == 'set')
        batch.set(docRef, op['data']);
      else if (op['type'] == 'update')
        batch.update(docRef, op['data']);
      else if (op['type'] == 'delete')
        batch.delete(docRef);
    }
    await batch.commit();
  }

  // Run transaction with retry
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) updateFunction,
  ) async {
    return await firestore.runTransaction(updateFunction);
  }

  // Create subcollection
  Future<void> createSubcollection(
    String parentCollection,
    String parentDocId,
    String subcollection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    await firestore
        .collection(parentCollection)
        .doc(parentDocId)
        .collection(subcollection)
        .doc(docId)
        .set(data);
  }

  // Query with pagination
  Future<List<DocumentSnapshot>> paginatedQuery(
    String collection,
    int pageSize,
    DocumentSnapshot? startAfter,
  ) async {
    Query query = firestore.collection(collection).limit(pageSize);
    if (startAfter != null) query = query.startAfterDocument(startAfter);
    final snapshot = await query.get();
    return snapshot.docs;
  }
}
