<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white"/>
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black"/>
  <img src="https://img.shields.io/badge/Firestore-FF6F00?style=for-the-badge&logo=firebase&logoColor=white"/>
  <img src="https://img.shields.io/badge/Riverpod-0553B1?style=for-the-badge&logo=dart&logoColor=white"/>
</p>

<h1 align="center">💈 Barbearia Elite — BarberFlow MVP</h1>

<p align="center">
  <b>Aplicativo mobile de agendamento para barbearias com dois perfis de usuário, dashboard financeiro em tempo real e design system Dark + Gold.</b>
</p>

<p align="center">
  <a href="#-sobre-o-projeto">Sobre</a> •
  <a href="#-funcionalidades">Funcionalidades</a> •
  <a href="#-arquitetura">Arquitetura</a> •
  <a href="#-stack-técnica">Stack</a> •
  <a href="#-como-executar">Como Executar</a> •
  <a href="#-próximos-passos">Roadmap</a>
</p>

---

## 🔍 Sobre o Projeto

O **BarberFlow** é um MVP de aplicativo mobile desenvolvido em Flutter para gestão completa de barbearias. O sistema atende dois perfis de usuário — **cliente** e **profissional** — com fluxos independentes e banco de dados em tempo real via Cloud Firestore.

O projeto demonstra domínio de desenvolvimento mobile com Flutter, arquitetura feature-first, gerenciamento de estado reativo com Riverpod e integração com serviços de cloud Firebase.

---

## ✨ Funcionalidades

### 👤 Perfil Cliente
- ✅ Registro e login com e-mail e senha (Firebase Auth)
- ✅ Agendamento de horário com seleção de data e hora
- ✅ Tela de resumo e confirmação do agendamento
- ✅ Lista de agendamentos em tempo real — Próximos e Histórico
- ✅ Notificações de status do agendamento

### ✂️ Perfil Profissional
- ✅ Dashboard com visão geral do dia
- ✅ Agenda diária com agendamentos em tempo real
- ✅ **Dashboard Financeiro** — faturamento total, comissão e ticket médio
- ✅ Gerenciamento de serviços oferecidos
- ✅ Painel administrativo de usuários

---

## 🏗️ Arquitetura

O projeto segue a arquitetura **Feature-First**, separando responsabilidades por domínio de negócio:

```
app/
├── lib/
│   ├── main.dart
│   ├── firebase_options.dart          # Configuração Firebase (não versionado)
│   │
│   ├── features/                      # Módulos por funcionalidade
│   │   ├── auth/                      # Login e Registro
│   │   ├── splash/                    # Splash + Roteamento por Role
│   │   ├── client/                    # Telas do Cliente
│   │   └── professional/              # Telas do Profissional
│   │
│   └── src/
│       ├── core/
│       │   ├── auth/                  # AuthService + Providers
│       │   ├── database/              # FirestoreService
│       │   └── models/                # UserModel, AppointmentModel
│       ├── routing/                   # GoRouter + AppRoutes
│       └── theme/                     # Design System (Dark + Gold)
```

### Fluxo de Roteamento por Role

```
App Start
    │
    ▼
SplashScreen
    │
    ├── Não autenticado → LoginScreen / RegisterScreen
    │
    └── Autenticado
            │
            ├── Role: client       → ClientDashboard
            └── Role: professional → ProfessionalDashboard
```

---

## 🛠️ Stack Técnica

| Tecnologia | Versão | Propósito |
|---|---|---|
| **Flutter** | ≥ 3.x | Framework mobile multiplataforma |
| **Dart** | ≥ 3.x | Linguagem de programação |
| **Firebase Auth** | — | Autenticação por e-mail e senha |
| **Cloud Firestore** | — | Banco de dados NoSQL em tempo real |
| **Riverpod** | ≥ 2.x | Gerenciamento de estado reativo |
| **GoRouter** | ≥ 12.x | Navegação declarativa com roteamento por role |

### Por que essas escolhas?

**Riverpod** foi escolhido sobre Provider e Bloc pela sua tipagem segura, suporte nativo a async/await e facilidade de teste unitário — padrão recomendado pela comunidade Flutter em 2024.

**GoRouter** foi escolhido pela navegação declarativa que facilita o roteamento baseado em roles (cliente vs. profissional) sem aninhamento complexo de rotas.

**Cloud Firestore** permite atualizações em tempo real via streams — essencial para que o profissional veja novos agendamentos instantaneamente sem precisar recarregar a tela.

---

## 📱 Telas

| Tela | Descrição |
|---|---|
| `login.html` | Autenticação de usuário |
| `register.html` | Cadastro de novo usuário |
| `onboarding.html` | Boas-vindas e seleção de perfil |
| `home.html` | Dashboard do cliente |
| `agendamento.html` | Fluxo de agendamento |
| `agenda.html` | Agenda do profissional |
| `painel.html` | Painel administrativo |
| `financas.html` | Dashboard financeiro |
| `relatorios.html` | Relatórios de atendimento |
| `fila.html` | Fila de espera em tempo real |
| `broadcast.html` | Notificações para clientes |
| `notificacoes.html` | Central de notificações |
| `perfil.html` | Perfil do usuário |
| `servicos.html` | Gerenciamento de serviços |
| `usuarios.html` | Gestão de usuários (admin) |

---

## 🚀 Como Executar

**Pré-requisitos:** Flutter SDK instalado, conta Firebase e FlutterFire CLI configurado.

```bash
# Clone o repositório
git clone https://github.com/alexsander020/Barbearia_Elite.git
cd Barbearia_Elite/app

# Instale as dependências
flutter pub get

# Configure o Firebase
# Crie um projeto no Firebase Console e execute:
flutterfire configure

# Execute o app
flutter run
```

> ⚠️ O arquivo `firebase_options.dart` não está versionado por segurança. Você precisará configurar seu próprio projeto Firebase e gerar o arquivo com o FlutterFire CLI.

---

## 🗺️ Próximos Passos

- [ ] **Gráfico de faturamento mensal** — visualização histórica com `fl_chart`
- [ ] **Sistema de avaliações** — clientes avaliam o profissional após o atendimento
- [ ] **Push notifications** — lembretes de agendamento via Firebase Cloud Messaging
- [ ] **Pagamento in-app** — integração com Stripe ou Mercado Pago
- [ ] **Modo offline** — cache local com Hive para funcionar sem internet
- [ ] **Testes unitários** — cobertura dos providers Riverpod com mocktail
- [ ] **Publicação na Play Store** — build de produção com CI/CD via GitHub Actions

---


## 👤 Autor Principal

**Alexsander Sudario Abreu**
Estudante de Ciência da Computação — FECAP, São Paulo

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=flat&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/alexsander-sudario-0a793524a/)
[![GitHub](https://img.shields.io/badge/GitHub-181717?style=flat&logo=github&logoColor=white)](https://github.com/alexsander020)

---

<p align="center">
  <i>Veja também: <a href="https://github.com/alexsander020/MedConnect_Application">💊 MedConnect</a> — Plataforma web com TDD e CI/CD · <a href="https://github.com/alexsander020/NexusData">📊 NexusData</a> — Dashboard BI com Machine Learning</i>
</p>
