import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/appointment_model.dart';
import '../auth/auth_service.dart';

// Provedor do Firestore
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Provedor do Serviço de Banco de Dados
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService(ref.watch(firestoreProvider));
});

// Provedor que busca os dados do usuário atualmente logado
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authUser = ref.watch(authStateChangesProvider).value;
  if (authUser == null) return null;
  
  return ref.watch(firestoreServiceProvider).getUser(authUser.uid);
});

class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService(this._db);

  // ── Users Collection ──

  /// Salva um novo usuário no Firestore após o registro
  Future<void> createUserProfile(UserModel user) async {
    await _db.collection('users').doc(user.id).set(user.toJson());
  }

  /// Busca o perfil de um usuário pelo ID
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar usuário: $e');
      return null;
    }
  }

  /// Atualiza o perfil de um usuário
  Future<void> updateUserProfile(UserModel user) async {
    await _db.collection('users').doc(user.id).update(user.toJson());
  }

  // ── Appointments Collection ──

  /// Cria um novo agendamento
  Future<void> createAppointment(AppointmentModel appointment) async {
    final docRef = _db.collection('appointments').doc(); // Auto-ID
    
    // Como o ID é gerado pelo Firestore, usamos o ID gerado para salvar.
    // Mas no modelo já recebemos um ID vazio ou pré-gerado. Vamos forçar o docRef.id.
    final appointmentToSave = appointment.id.isEmpty 
        ? AppointmentModel(
            id: docRef.id,
            clientId: appointment.clientId,
            clientName: appointment.clientName,
            professionalId: appointment.professionalId,
            professionalName: appointment.professionalName,
            serviceName: appointment.serviceName,
            price: appointment.price,
            dateTime: appointment.dateTime,
            status: appointment.status,
            createdAt: appointment.createdAt,
          )
        : appointment;

    await _db.collection('appointments').doc(appointmentToSave.id).set(appointmentToSave.toJson());
  }

  /// Retorna um Stream de agendamentos para um cliente específico
  Stream<List<AppointmentModel>> getClientAppointments(String clientId) {
    return _db
        .collection('appointments')
        .where('clientId', isEqualTo: clientId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => AppointmentModel.fromJson(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return list;
    });
  }

  /// Stream de agendamentos de um profissional a partir de uma data
  Stream<List<AppointmentModel>> getProfessionalAppointments(String professionalId, DateTime from) {
    return _db
        .collection('appointments')
        .where('professionalId', isEqualTo: professionalId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => AppointmentModel.fromJson(doc.data(), doc.id))
          .where((a) => a.dateTime.isAfter(from) && a.status != 'canceled')
          .toList();
      list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return list;
    });
  }
}
