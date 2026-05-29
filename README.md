# Barbearia Elite — BarberFlow MVP

Aplicativo de agendamento para barbearias, construído com Flutter + Firebase.

## Tecnologias

- **Flutter** (Dart)
- **Firebase Auth** — Autenticação por e-mail/senha
- **Cloud Firestore** — Banco de dados em tempo real
- **Riverpod** — Gerenciamento de estado
- **GoRouter** — Navegação declarativa

## Funcionalidades

### Cliente
- ✅ Registro e Login com e-mail e senha
- ✅ Agendamento de horário (data + hora)
- ✅ Resumo e confirmação do agendamento (salvo no Firestore)
- ✅ Lista de agendamentos em tempo real (Próximos e Histórico)

### Profissional
- ✅ Dashboard com visão geral do dia
- ✅ Agenda diária
- ✅ Dashboard Financeiro Real (faturamento, comissão, ticket médio)
- ✅ Gerenciamento de Serviços (estrutura base)

## Configuração

1. Clone o repositório
2. Execute `flutter pub get` dentro da pasta `app/`
3. Configure seu próprio projeto Firebase e gere o `firebase_options.dart` com o FlutterFire CLI
4. Execute `flutter run`

## Estrutura do Projeto

```
app/
├── lib/
│   ├── main.dart
│   ├── firebase_options.dart
│   ├── features/
│   │   ├── auth/          # Login e Registro
│   │   ├── splash/        # Splash + Roteamento por Role
│   │   ├── client/        # Telas do Cliente
│   │   └── professional/  # Telas do Profissional
│   └── src/
│       ├── core/
│       │   ├── auth/      # AuthService + Providers
│       │   ├── database/  # FirestoreService
│       │   └── models/    # UserModel, AppointmentModel
│       ├── routing/       # GoRouter + AppRoutes
│       └── theme/         # Design System (Dark + Gold)
```
