# Move Challenge

Aplicativo de desafio de atividade física em grupo. Cada pessoa marca os dias em que se movimentou, acumula pontos e sequências, e acompanha o ranking do grupo em tempo real.

## Funcionalidades

- Conta com e-mail e senha, incluindo recuperação de senha.
- Criação de desafio com código de convite de 6 caracteres.
- Marcação diária: treino, dia leve ou coringa, com opção de treino com alguém do desafio (presencial ou por chamada de vídeo).
- Calendário mensal com status por cor, ícone e borda (acessível para daltonismo e leitores de tela).
- Ranking do mês e desde o início, com compartilhamento em texto.
- Comemoração ao atingir 7, 14 e 30 dias seguidos.
- Tema claro, escuro ou automático.

## Regras de pontuação

| Situação | Pontos |
|---|---|
| Dia com atividade (20 a 30 minutos ou mais) | 1 |
| Dia leve | 1 |
| Treino com alguém do desafio, junto ou por chamada de vídeo | +1 |
| 7 / 14 / 30 dias seguidos | +3 / +5 / +10 |
| Coringa (1 por mês) | 0, mas não quebra a sequência |

## Tecnologias

- Flutter e Dart
- Firebase Authentication e Cloud Firestore
- Provider para injeção de dependências
- flutter_test para testes de unidade e de widget
- Mocha e @firebase/rules-unit-testing para testar as regras de segurança
- GitHub Actions para integração contínua

## Estrutura

```
lib/
  domain/        Regras de negócio puras (pontuação, ranking, datas, validações)
  data/          Interfaces de repositório e implementação com Firebase
  ui/            Tema, componentes e telas
test/
  domain/        Testes de unidade das regras de negócio
  widget/        Testes de componentes e telas
firestore-tests/ Testes das regras de segurança no emulador
firestore.rules  Regras de segurança do banco
```

As telas dependem apenas das interfaces em `lib/data/repositories.dart`. Por isso os testes de tela usam implementações falsas e não precisam de Firebase.

## Como rodar no Windows

### 1. Instalar as ferramentas

1. Instale o Flutter seguindo o guia oficial para Windows (versão estável) e adicione a pasta `flutter\bin` ao PATH.
2. Instale o Android Studio. Na primeira abertura, deixe ele instalar o Android SDK.
3. No terminal (PowerShell), rode `flutter doctor` e resolva o que aparecer em vermelho. Para aceitar as licenças do Android: `flutter doctor --android-licenses`.
4. Instale o Node.js (versão LTS) e depois o Firebase CLI: `npm install -g firebase-tools`.

### 2. Criar o projeto no Firebase

1. Acesse o console do Firebase e crie um projeto (o Google Analytics pode ficar desativado).
2. Em **Authentication**, ative o método **E-mail/senha**.
3. Em **Firestore Database**, crie o banco em modo de produção, na região `southamerica-east1` (São Paulo).

### 3. Gerar as pastas de plataforma

Na pasta do projeto:

```powershell
flutter create . --project-name move_challenge --org com.pamelatf --platforms android,web
flutter pub get
```

O comando cria as pastas `android/` e `web/` sem alterar o código em `lib/` e `test/`.

Se o `flutter pub get` reclamar de versões, rode `flutter pub upgrade --major-versions`.

### 4. Conectar o app ao Firebase

```powershell
firebase login
dart pub global activate flutterfire_cli
flutterfire configure
```

No `flutterfire configure`, escolha o projeto criado e marque as plataformas **android** e **web**. O comando substitui o arquivo `lib/firebase_options.dart`.

### 5. Ajustes no Android

Em `android/app/build.gradle.kts` (ou `build.gradle`), dentro de `defaultConfig`, defina:

```kotlin
minSdk = 23
```

Em `android/app/src/main/AndroidManifest.xml`:

- troque `android:label="move_challenge"` por `android:label="Move Challenge"`;
- confirme que existe a linha `<uses-permission android:name="android.permission.INTERNET"/>` antes da tag `<application>`.

### 6. Publicar as regras de segurança

```powershell
firebase use --add
firebase deploy --only firestore:rules
```

### 7. Rodar

Com um celular Android conectado por USB (depuração USB ativada) ou um emulador aberto:

```powershell
flutter run
```

## Gerar o APK

```powershell
flutter build apk --release
```

O arquivo fica em `build\app\outputs\flutter-apk\app-release.apk`. Envie para as participantes (por exemplo, pelo WhatsApp ou Google Drive). Ao abrir, o Android pede para permitir a instalação de fontes desconhecidas.

O APK é assinado com a chave de depuração, o que funciona para distribuição direta entre amigas, mas não para a Play Store.

## Versão web para iPhone

```powershell
flutter build web
firebase deploy --only hosting
```

No iPhone, abra o endereço publicado no Safari, toque em **Compartilhar** e depois em **Adicionar à Tela de Início**.

## Testes

```powershell
flutter test
```

Testes das regras do Firestore (precisam de Java 21 instalado):

```powershell
cd firestore-tests
npm install
npm run test:emulador
```

### Testes de ponta a ponta (Maestro)

Os fluxos ficam em `.maestro/` e rodam em um emulador Android, com o app conectado aos emuladores do Firebase (nunca ao projeto real). Para rodar localmente, com o emulador Android aberto e o [Maestro](https://maestro.mobile.dev) instalado:

```powershell
firebase emulators:start --only auth,firestore --project move-challenge-b5aa8
flutter build apk --debug --dart-define=USE_FIREBASE_EMULATORS=true
adb install build/app/outputs/flutter-apk/app-debug.apk
maestro test .maestro
```

A versão de depuração precisa permitir conexão sem HTTPS com os emuladores. Isso está configurado em `android/app/src/debug/AndroidManifest.xml`.

### Mapa da automação

Cada teste traz no nome um identificador e as regras que cobre, por exemplo `UNI-06 [RN1] treino e dia leve valem 1 ponto cada`. O script abaixo lê todos os testes e gera a página de mapa da wiki:

```powershell
node scripts/gerar-mapa-automacao.js
```

## Integração contínua

O workflow `.github/workflows/ci.yml` roda a cada push na branch `main`:

1. análise estática e testes Flutter;
2. testes das regras de segurança no emulador do Firestore;
3. geração do APK, disponível para download na aba **Actions** do GitHub, na seção **Artifacts**;
4. testes de ponta a ponta com Maestro em emulador Android, com relatório e capturas de tela publicados como artefato.

Para o job do APK funcionar, os arquivos gerados nos passos 3 a 5 (`android/`, `web/` e `lib/firebase_options.dart`) precisam estar no repositório.

## Sobre as chaves do Firebase

Os valores em `firebase_options.dart` identificam o projeto, mas não são senhas. A proteção dos dados vem das regras em `firestore.rules`, que garantem, por exemplo, que cada pessoa só altera os próprios dias e que só participantes leem os dados do desafio.

## Limitações conhecidas

- O tema escolhido no Perfil não fica salvo depois de fechar o app.
- O limite de um coringa por mês é validado no app, não nas regras do banco.
- O calendário de outra participante mostra os dados do momento em que foi aberto.
