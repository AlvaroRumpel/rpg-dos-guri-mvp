# RPG dos Guri

MVP Flutter Web/PWA para controlar fichas, combate, vida, status, poderes usados, consumiveis, monstros e progressao basica.

O app nao rola dados, nao decide acerto e nao aplica dano a partir de rolagem. Toda automacao deve economizar contagem, nao decisao.

Estado atual: MVP Flutter Web com `provider` e Firestore. O app inicializa Firebase quando `lib/firebase_options.dart` existe e cai para dados locais seedados se Firebase estiver indisponivel.

O fluxo online atual permite entrar/criar mesa por codigo `GURI-0000`, persistir fichas, pendencias de aprovacao, combate ativo/inativo e logs informativos no Firestore.

As regras oficiais do vault do Obsidian sao importadas para JSON versionado em `assets/data/official/`. O app nao le o vault em runtime.

## Rodar localmente

```powershell
cd F:\_geral\Projetos\rpg-dos-guri-mvp
flutter pub get
flutter run -d chrome
```

## Firebase

As dependencias de Firebase ja estao no projeto e o app ja inicializa `Firebase.initializeApp`.

1. Crie um projeto no Firebase Console.
2. Ative Cloud Firestore.
3. Instale/configure o FlutterFire CLI:

```powershell
dart pub global activate flutterfire_cli
flutterfire configure
```

4. O comando deve gerar ou atualizar `lib/firebase_options.dart`.
5. Rode `flutter analyze` e `flutter build web`.

Deploy domestico:

```powershell
firebase deploy --only hosting,firestore:rules
```

URL publicada atual:

```text
https://rpgdosguri.web.app
```

Arquivos ja preparados para a etapa online:

- `firebase.json`
- `firestore.rules`
- `firestore.indexes.json`
- `lib/features/rpg/data/rpg_repositories.dart`
- `lib/features/rpg/data/firestore_rpg_repositories.dart`
- `lib/features/rpg/data/rpg_firestore_mappers.dart`

Enquanto Firebase estiver indisponivel, o app roda com dados seedados em memoria para validar fluxo, telas e regras.

## Bibliotecas oficiais

Fonte padrao somente leitura:

```text
E:\Obsidian\RPG dos Guri\90 Fontes Oficiais
```

Gerar os assets oficiais:

```powershell
dart run tools/import_official_vault.dart
```

Se o vault estiver em outro caminho:

```powershell
dart run tools/import_official_vault.dart --vault "E:\Outro\Caminho"
```

O comando atualiza:

- `assets/data/official/races.json`
- `assets/data/official/classes.json`
- `assets/data/official/progression.json`
- `assets/data/official/spells.json`
- `assets/data/official/rituals.json`
- `assets/data/official/powers.json`
- `assets/data/official/equipment.json`
- `assets/data/official/items.json`
- `assets/data/official/starter_kits.json`
- `assets/data/official/monsters.json`

## Documentacao

Veja [docs/architecture.md](docs/architecture.md).

Especificacao completa: [docs/specification.md](docs/specification.md).

Status de implementacao: [docs/implementation-status.md](docs/implementation-status.md).
