import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provedor que expõe a instância do FirebaseAuth
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Provedor que escuta as mudanças de estado de autenticação (logado/deslogado)
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// Provedor do nosso serviço de autenticação
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(firebaseAuthProvider));
});

class AuthService {
  final FirebaseAuth _auth;

  AuthService(this._auth);

  /// Retorna o usuário logado no momento, ou null se não houver.
  User? get currentUser => _auth.currentUser;

  /// Registra um novo usuário com e-mail e senha.
  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Aqui podemos tratar erros específicos, como e-mail já em uso
      throw _handleAuthException(e);
    }
  }

  /// Faz o login de um usuário existente com e-mail e senha.
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Desloga o usuário atual.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Traduz os erros do Firebase para mensagens amigáveis em português
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Nenhum usuário encontrado com este e-mail.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'email-already-in-use':
        return 'Este e-mail já está em uso por outra conta.';
      case 'invalid-email':
        return 'O endereço de e-mail é inválido.';
      case 'weak-password':
        return 'A senha fornecida é muito fraca (mínimo de 6 caracteres).';
      default:
        return 'Ocorreu um erro na autenticação. Tente novamente.';
    }
  }
}
