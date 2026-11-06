import 'package:cloud_firestore/cloud_firestore.dart';

import '../Models/transaction_model.dart';
import 'auth_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  String get userId => AuthService().currentUser!.uid;

  CollectionReference<Map<String, dynamic>>
      get transactionCollection {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions');
  }

  Stream<List<TransactionModel>> getTransactions() {
    return transactionCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TransactionModel.fromDocument(doc))
          .toList();
    });
  }

  Future<void> addTransaction(
    TransactionModel transaction,
  ) async {
    await transactionCollection.add(transaction.toMap());
  }

  Future<void> updateTransaction(
    TransactionModel transaction,
  ) async {
    await transactionCollection
        .doc(transaction.id)
        .update(transaction.toMap());
  }

  Future<void> deleteTransaction(String id) async {
    await transactionCollection.doc(id).delete();
  }
}