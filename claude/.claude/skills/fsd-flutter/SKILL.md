---
name: fsd-flutter
description: Generate Flutter code following Clean Architecture + FSD. Creates features with BLoC, Freezed models, Retrofit API clients, and get_it DI — fully compatible with fsd-backend Spring Boot API format.
---

# fsd-flutter: Flutter Clean Architecture + FSD Skill

You are an expert Flutter developer. When the user asks to generate Flutter code, follow all patterns described below strictly. Generate complete, production-ready code — no placeholders, no TODOs.

**Перед генерацией кода** прочитай шаблоны из `templates/` — они содержат полные реализации с импортами. Каждый шаблон — готовый файл для подстановки `{Name}` / `{name}`.

## ВАЖНО: Разведка проекта перед генерацией

**Перед генерацией любого кода** проверь существующий проект:

1. **pubspec.yaml** — какие пакеты установлены
2. **lib/core/theme/** — есть ли AppColors, AppTextStyles, AppDimens
3. **lib/core/constants/** — есть ли существующие константы
4. **lib/shared/widgets/** — есть ли готовые виджеты

**Правила:**
- Если есть `AppDimens`, `AppSpacing`, `AppColors`, `AppTextStyles` — используй их
- Если есть `flutter_screenutil` → используй `.w`, `.h`, `.sp`
- Если есть кастомные виджеты (`AppButton`, `AppTextField`) → используй их
- Если **ничего нет** — используй `Theme.of(context)` и стандартные Material-виджеты
- **НИКОГДА** не хардкодь `Color(0xFF...)`, `EdgeInsets.all(16)`, `fontSize: 14` напрямую в UI

---

## 1. Архитектура, слои и импорты

Clean Architecture + Feature-Sliced Design. Dependency Rule: `presentation → domain ← data`.

```
lib/
├── app/                          # DI (injection.dart), Router (app_router.dart), app.dart, main.dart
├── core/                         # error/failures.dart, network/, constants/, theme/, usecases/
├── features/{name}/
│   ├── data/                     # datasources/, models/, repositories/
│   ├── domain/                   # entities/, params/, repositories/, usecases/
│   └── presentation/             # bloc/, cubit/, pages/, widgets/
└── shared/                       # models/ (BaseResponse, PageData), widgets/
```

### Правила слоёв и импорта

| Слой | Может зависеть от | НЕ может зависеть от |
|------|-------------------|---------------------|
| `domain/` | `dart:core`, `fpdart`, `freezed_annotation` | `data/`, `presentation/`, Flutter SDK |
| `data/` | `domain/`, `core/`, `shared/models/` | `presentation/` |
| `presentation/` | `domain/`, `core/`, `shared/` | `data/` (только через DI) |

- Фичи **НЕ** импортируют друг друга. Общее — в `shared/`.
- Relative imports внутри фичи, absolute для `core/` и `shared/`.
- Domain entity **никогда** не имеет `fromJson`/`toJson`.
- Domain Params — Freezed **без** `fromJson`/`toJson`. RepositoryImpl конвертирует params → request DTOs.

---

## 2. Совместимость с бэкендом (fsd-backend)

### API Endpoints

| Метод | URL | Назначение |
|-------|-----|-----------|
| `GET /{id}` | Получить по ID |
| `POST /filter` | Список с пагинацией (**НЕ** `GET /all`) |
| `POST /` | Создание |
| `PUT /` | Обновление |
| `DELETE /{id}` | Мягкое удаление |

Если пользователь указал конкретные URL — используй их, а не шаблонные.

### BaseResponse — обёртка всех ответов

```json
{ "success": true, "message": "optional", "result": { ... } }
```

### POST /filter — пагинация

```json
{
  "page": 0, "size": 15, "search": "...",
  "sortBy": "createdAt", "sortDirection": "DESC"
}
```

Result: `{ "content": [...], "page": 0, "size": 15, "totalElements": 100, "totalPages": 7 }`

### Стандартные поля сущностей

- `id` (int), `createdAt` (String, ISO 8601), `updatedAt` (String) — всегда в Response
- **ВСЕГДА** включай `createdAt`/`updatedAt` в Entity и Model, даже если пользователь не указал

### Failure и HTTP-коды

```dart
// lib/core/error/failures.dart — Freezed union type
// 400 → Failure.badRequest, 401 → .unauthorized, 403 → .forbidden,
// 404 → .notFound, 409 → .conflict, 500+ → .serverError
```

Полный код Failure — в секции ниже или в templates.

---

## 3. Shared Models

Эти модели живут **ТОЛЬКО** в `lib/shared/models/` и используются всеми фичами.

> **КРИТИЧНО:** Импорт shared моделей — `../../../../shared/models/base_response.dart` и `../../../../shared/models/page_data.dart`. **НИКОГДА** не используй `core/models/` — такого пути не существует. BaseResponse и PageData — это `shared/models/`, не `core/models/`.

### BaseResponse

> **ВАЖНО:** Поле с данными называется `result`, **НЕ** `data`. Всегда обращайся через `response.result`, **НИКОГДА** через `response.data`.

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'base_response.freezed.dart';
part 'base_response.g.dart';

@Freezed(genericArgumentFactories: true)
class BaseResponse<T> with _$BaseResponse<T> {
  const factory BaseResponse({
    required bool success,
    String? message,
    T? result,        // ← ИМЕННО result, НЕ data
  }) = _BaseResponse;

  factory BaseResponse.fromJson(
    Map<String, dynamic> json, T Function(Object?) fromJsonT,
  ) => _$BaseResponseFromJson(json, fromJsonT);
}
```

### PageData

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'page_data.freezed.dart';
part 'page_data.g.dart';

@Freezed(genericArgumentFactories: true)
class PageData<T> with _$PageData<T> {
  const factory PageData({
    required List<T> content,
    required int page,
    required int size,
    required int totalElements,
    required int totalPages,
  }) = _PageData;

  factory PageData.fromJson(
    Map<String, dynamic> json, T Function(Object?) fromJsonT,
  ) => _$PageDataFromJson(json, fromJsonT);
}
```

---

## 4. Failure

> **КРИТИЧНО:** `Failure` — это **Freezed union type** с factory-конструкторами. Используй **ТОЛЬКО** `Failure.serverError(message: ...)`, `Failure.badRequest(message: ...)` и т.д. **НИКОГДА** не создавай отдельные классы вроде `ServerFailure(...)`, `BadRequestFailure(...)` — их не существует. Единственный класс — `Failure` с named-конструкторами.

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'failures.freezed.dart';

@freezed
class Failure with _$Failure {
  const Failure._();
  const factory Failure.serverError({@Default('Server error') String message}) = _ServerError;
  const factory Failure.badRequest({@Default('Bad request') String message}) = _BadRequest;
  const factory Failure.unauthorized() = _Unauthorized;
  const factory Failure.forbidden() = _Forbidden;
  const factory Failure.notFound({@Default('Not found') String message}) = _NotFound;
  const factory Failure.conflict({@Default('Conflict') String message}) = _Conflict;
  const factory Failure.networkError({@Default('No internet connection') String message}) = _NetworkError;
  const factory Failure.unexpected({@Default('Unexpected error') String message}) = _Unexpected;

  String get message => when(
    serverError: (msg) => msg, badRequest: (msg) => msg,
    unauthorized: () => 'Необходима авторизация', forbidden: () => 'Доступ запрещён',
    notFound: (msg) => msg, conflict: (msg) => msg,
    networkError: (msg) => msg, unexpected: (msg) => msg,
  );
}
```

---

## 5. Feature Files — шаблоны

Все шаблоны лежат в `templates/`. **Прочитай их перед генерацией** — они содержат полные реализации с правильными импортами.

### Domain слой

| Файл | Шаблон | Ключевые правила |
|-------|--------|-----------------|
| `{name}_entity.dart` | [templates/domain/entity.dart.template](./templates/domain/entity.dart.template) | Freezed, без fromJson, с createdAt/updatedAt |
| `{name}_filter_params.dart` | [templates/domain/filter_params.dart.template](./templates/domain/filter_params.dart.template) | Freezed, **без** fromJson, поля page/size/search/sortBy/sortDirection + кастомные |
| `create_{name}_params.dart` | [templates/domain/create_params.dart.template](./templates/domain/create_params.dart.template) | Freezed, **без** fromJson, бизнес-поля |
| `update_{name}_params.dart` | [templates/domain/update_params.dart.template](./templates/domain/update_params.dart.template) | Как create + `required int id` |
| `{name}_repository.dart` | [templates/domain/repository.dart.template](./templates/domain/repository.dart.template) | Abstract, принимает domain params, возвращает `Either<Failure, T>` |
| UseCases (5 шт) | [templates/domain/usecase_*.dart.template](./templates/domain/) | `@injectable`, один UseCase = одна операция, делегирует в Repository |

**Base UseCase:**
```dart
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}
```

### Data слой

| Файл | Шаблон | Ключевые правила |
|-------|--------|-----------------|
| `{name}_model.dart` | [templates/data/model.dart.template](./templates/data/model.dart.template) | Freezed + fromJson + `toEntity()` — единственный маппинг, без mapper-классов |
| `create_{name}_request.dart` | [templates/data/create_request.dart.template](./templates/data/create_request.dart.template) | Freezed + fromJson, поля без id/createdAt/updatedAt |
| `update_{name}_request.dart` | [templates/data/update_request.dart.template](./templates/data/update_request.dart.template) | Как create + `required int id` |
| `{name}_filter_request.dart` | [templates/data/filter_request.dart.template](./templates/data/filter_request.dart.template) | Зеркалит FilterParams, но **с** fromJson |
| `{name}_remote_ds.dart` | [templates/data/remote_ds.dart.template](./templates/data/remote_ds.dart.template) | Retrofit `@RestApi()`, `@injectable` + `@factoryMethod`, return `Future<BaseResponse<T>>` |
| `{name}_repository_impl.dart` | [templates/data/repository_impl.dart.template](./templates/data/repository_impl.dart.template) | `@Injectable(as: Repo)`, params→request конвертация, try/catch DioException→Failure, проверка `response.success` |

**Правила RepositoryImpl:**
- Всегда try/catch с DioException → `_mapDioError` **+ отдельный `catch (e)` для unexpected ошибок**
- **ОБЯЗАТЕЛЬНО** включай метод `_mapDioError` с маппингом статус-кодов в Failure union (400→badRequest, 401→unauthorized, 403→forbidden, 404→notFound, 409→conflict, _→serverError). Без этого метода теряется гранулярность ошибок
- Обращайся к данным через `response.result`, **НЕ** `response.data`
- Проверяй `response.success` — бэкенд может вернуть 200 с `success: false`
- При ошибке используй `Failure.serverError(message: ...)`, **НЕ** `ServerFailure(...)`
- `toEntity()` вызывается в repository, не в BLoC

### Presentation слой

| Файл | Шаблон | Ключевые правила |
|-------|--------|-----------------|
| List BLoC (event/state/bloc) | [templates/presentation/list_*.dart.template](./templates/presentation/) | Events: fetch/loadMore/refresh/updateFilter. State: items/filter/isLoading/isLoadingMore/hasReachedEnd |
| Detail BLoC | [templates/presentation/detail_*.dart.template](./templates/presentation/) | State — union type: initial/loading/loaded/deleted/error |

**Когда BLoC, когда Cubit:**

| Компонент | Используй |
|-----------|----------|
| Списки, пагинация, сложные потоки | **BLoC** (Events + States) |
| Формы, toggle, простые действия | **Cubit** (методы) |

---

## 6. Forms — два подхода

### Простой Cubit (2-4 поля, простая валидация)

State с полями + `fieldErrors: Map<String, String>` + `_validate()`. См. пример в EXAMPLES.md.

### Formz (рекомендуемый для сложных форм)

FormzInput для type-safe валидации:
```dart
class NameInput extends FormzInput<String, NameValidationError> {
  const NameInput.pure() : super.pure('');
  const NameInput.dirty([super.value = '']) : super.dirty();
  @override
  NameValidationError? validator(String value) { ... }
}
```

State с FormzInput полями + `FormzSubmissionStatus` + `bool get isValid => Formz.validate([...])`.

**Правила форм:**
- **ВСЕГДА** `TextFormField` + `initialValue` + `BlocBuilder` с `buildWhen`. **НИКОГДА** `TextEditingController` в builder.
- `BlocListener` на уровне страницы для side-effects (навигация, снекбар).
- Кнопка submit: `onPressed: state.isSubmitting ? null : cubit.submit`.

Полные примеры форм: [EXAMPLES.md — Пример 4, 5](./EXAMPLES.md).

---

## 7. Core Infrastructure

### DI (get_it + injectable)

```dart
final getIt = GetIt.instance;
@InjectableInit()
Future<void> configureDependencies() async => getIt.init();
```

- `@injectable` — все BLoC, Cubit, UseCase, RepositoryImpl
- `@Injectable(as: Repository)` — для abstract → implementation
- `@singleton` — Dio, AuthInterceptor, AppRouter
- `@module abstract class` — для сторонних классов (Dio)
- Retrofit: `@injectable` + `@factoryMethod` на factory-конструкторе
- В виджетах: `BlocProvider(create: (_) => getIt<Bloc>()..add(Event.fetch()))`

### Network (Dio + Retrofit)

- Dio с BaseOptions (baseUrl из ApiConstants, timeouts, JSON headers)
- AuthInterceptor (`@singleton`) — Bearer token injection
- LogInterceptor для debug
- Retrofit clients — `@RestApi()`, `POST /filter` для списков, **НИКОГДА** `GET /all`

### Navigation (auto_route)

- `@AutoRouterConfig()` + `@singleton` на AppRouter
- `@RoutePage()` на каждой странице
- **ВСЕГДА** `context.router.push()` / `.replace()` / `.maybePop()` для навигации
- **НИКОГДА** не используй `Navigator.of(context).push(MaterialPageRoute(...))` — только auto_route API
- `@PathParam('id')` для параметров

Примеры навигации с табами: [EXAMPLES.md — Пример 6](./EXAMPLES.md).

---

## 8. Pagination — UI паттерн

Ключевые элементы infinite scroll:

1. **3 состояния**: loading (первая загрузка) → error (пустой список + ошибка) → empty
2. **RefreshIndicator** → `Event.refresh()`
3. **NotificationListener\<ScrollNotification\>** → loadMore при `maxScrollExtent - 200`
4. **itemCount**: `state.items.length + (state.isLoadingMore ? 1 : 0)`

Полный пример: [EXAMPLES.md — Пример 1](./EXAMPLES.md).

---

## 9. Naming Conventions

| Элемент | Конвенция | Пример |
|---------|----------|--------|
| Файлы / Feature папки | `snake_case` | `product_model.dart`, `features/product/` |
| Entity / Model / Repository | `{Name}Entity`, `{Name}Model`, `{Name}Repository` | `ProductEntity` |
| UseCase | `{ActionName}` | `GetProducts`, `CreateProduct` |
| Remote DS | `{Name}RemoteDs` | `ProductRemoteDs` |
| Request DTO / Params | `{Action}{Name}Request` / `{Action}{Name}Params` | `CreateProductRequest` / `CreateProductParams` |
| BLoC / Cubit | `{name}_list_bloc.dart` / `{name}_form_cubit.dart` | `product_list_bloc.dart` |
| Page / Widget | `{Name}{Action}Page` / `{Name}{Purpose}` | `ProductListPage`, `ProductCard` |

---

## 10. Anti-patterns

| Запрещено | Правильно |
|-----------|-----------|
| `GET /all` для списков | `POST /filter` |
| Прямой Dio в BLoC | UseCase → Repository |
| Бизнес-логика в Widget | BLoC/Cubit или UseCase |
| Импорт `data/` в `presentation/` | Через `domain/` и DI |
| Data DTOs в сигнатурах domain | Domain Params (`domain/params/`) |
| Mapper-классы | `toEntity()` метод в Model |
| `dynamic` в моделях | Типизированные поля с Freezed |
| `print()` | `LogInterceptor` в Dio |
| `TextEditingController` в builder | `TextFormField` + `initialValue` + `buildWhen` |
| `BuildContext` в BLoC | Передавай данные, не контекст |
| `late` без необходимости | Nullable или default |
| `part 'state.dart'` когда State в том же файле | Только `part 'cubit.freezed.dart'` |
| Хардкод цветов/размеров/стилей в виджетах | `AppColors`/`AppDimens`/`Theme.of(context)` |
| `ServerFailure(...)`, `BadRequestFailure(...)` | `Failure.serverError(message: ...)`, `Failure.badRequest(message: ...)` — Failure это freezed union |
| `response.data` в RepositoryImpl | `response.result` — поле BaseResponse называется `result` |
| `import 'core/models/...'` для BaseResponse/PageData | `import 'shared/models/...'` — shared модели в `lib/shared/models/` |
| `Navigator.of(context).push(MaterialPageRoute(...))` | `context.router.push(Route())` — всегда используй auto_route |
| RepositoryImpl без `_mapDioError` | Всегда включай `_mapDioError` для гранулярного маппинга HTTP-кодов в Failure |
| `hasReachedEnd: items.length >= totalElements` | `hasReachedEnd: pageData.page + 1 >= pageData.totalPages` — используй totalPages |

---

## 11. Testing

Шаблоны тестов: [templates/test/](./templates/test/).

| Тест | Шаблон | Что мокаем |
|------|--------|-----------|
| Repository | [repository_impl_test.dart.template](./templates/test/repository_impl_test.dart.template) | RemoteDs |
| UseCase | [usecase_test.dart.template](./templates/test/usecase_test.dart.template) | Repository |
| BLoC | [bloc_test.dart.template](./templates/test/bloc_test.dart.template) | UseCase |
| Моки | [mock_helpers.dart.template](./templates/test/mock_helpers.dart.template) | — |
| Тестовые данные | [test_data.dart.template](./templates/test/test_data.dart.template) | — |

**Правила:**
- `blocTest` — предпочтительный способ тестирования BLoC/Cubit
- `registerFallbackValue()` для Freezed-классов в `setUpAll`
- Мокай **только** прямые зависимости
- Минимальный набор при генерации фичи: Repository тест + BLoC тест

---

## 12. Code Generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

| Аннотация | Генерирует |
|-----------|-----------|
| `@freezed` | `*.freezed.dart` |
| `@freezed` с `fromJson` | `*.g.dart` |
| `@RestApi()` | `*.g.dart` |
| `@InjectableInit()` | `injection.config.dart` |
| `@AutoRouterConfig()` | `app_router.gr.dart` |

---

## 13. pubspec.yaml — зависимости

```yaml
dependencies:
  flutter_bloc: ^8.1.6
  bloc: ^8.1.4
  dio: ^5.7.0
  retrofit: ^4.4.1
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0
  get_it: ^8.0.2
  injectable: ^2.5.0
  auto_route: ^9.2.2
  fpdart: ^1.1.0
  formz: ^0.7.0
  flutter_screenutil: ^5.9.3
  equatable: ^2.0.5

dev_dependencies:
  build_runner: ^2.4.13
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  retrofit_generator: ^9.1.5
  injectable_generator: ^2.6.2
  auto_route_generator: ^9.0.0
  bloc_test: ^9.1.7
  mocktail: ^1.0.4
```

---

## 14. Shared Widgets (fallback)

Если в проекте нет готовых — создай `AppErrorWidget(message, onRetry)`, `AppLoadingWidget()`, `AppEmptyWidget(message)` в `lib/shared/widgets/`. Используй `Theme.of(context)` для стилей.

---

## 15. Theming (fallback)

Если в проекте нет темы — создай `AppColors` и `AppTheme` в `lib/core/theme/`. Используй Material 3 `ColorScheme.fromSeed()`. Это fallback — если тема уже есть, используй существующую.

---

## 16. Linting, форматирование и стиль кода

### analysis_options.yaml

При создании нового проекта или если `analysis_options.yaml` содержит только дефолтные правила — замени на эталонный конфиг:

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/*.gr.dart"
    - "**/*.config.dart"
    - "lib/generated/**"
  errors:
    invalid_annotation_target: ignore

linter:
  rules:
    # Style
    prefer_single_quotes: true
    prefer_const_constructors: true
    prefer_const_declarations: true
    prefer_const_literals_to_create_immutables: true
    prefer_final_locals: true
    prefer_final_in_for_each: true
    sort_child_properties_last: true
    use_super_parameters: true
    sized_box_for_whitespace: true
    unnecessary_const: true
    unnecessary_new: true
    unnecessary_this: true
    unnecessary_string_interpolations: true
    unnecessary_brace_in_string_interps: true

    # Safety
    avoid_print: true
    avoid_relative_lib_imports: true
    avoid_empty_else: true
    avoid_returning_null_for_future: true
    cancel_subscriptions: true
    close_sinks: true
    always_declare_return_types: true
    type_annotate_public_apis: true

    # Imports
    directives_ordering: true
    always_use_package_imports: false
    prefer_relative_imports: true

    # Readability
    require_trailing_commas: true
    cascade_invocations: false
    avoid_unnecessary_containers: true
    prefer_is_empty: true
    prefer_is_not_empty: true
    use_colored_box: true
    use_decorated_box: true
```

### Правила форматирования

| Правило | Значение |
|---------|----------|
| Длина строки | `80` символов (`dart format --line-length=80`) |
| Кавычки | Одинарные (`'string'`), не двойные |
| Trailing commas | **Обязательны** для всех multi-line аргументов и коллекций |
| Пустые строки | 1 между методами, 0 внутри метода (кроме логических блоков) |
| Импорты | 3 группы: `dart:`, `package:`, relative — разделены пустой строкой |
| Сортировка импортов | Алфавитная внутри каждой группы |

### Правила именования

| Элемент | Формат | Пример |
|---------|--------|--------|
| Файлы | `snake_case.dart` | `user_entity.dart` |
| Классы | `PascalCase` | `UserEntity` |
| Переменные, методы | `camelCase` | `getUserById` |
| Константы | `camelCase` (не `SCREAMING_CASE`) | `defaultPageSize` |
| Приватные поля | `_camelCase` | `_accessToken` |
| BLoC events | `PascalCase` (freezed union) | `UserEvent.fetch()` |
| BLoC states | `PascalCase` (freezed) | `UserListState` |
| Enum values | `camelCase` | `TransactionFilterType.credit` |

### Правила для генерируемого кода

1. **Весь код должен проходить `dart format` без изменений** — т.е. генерируй уже отформатированный код
2. **Весь код должен проходить `flutter analyze` без ошибок и warning-ов** (info допустимы для deprecated API)
3. **`const` везде, где возможно** — конструкторы, литералы, виджеты
4. **`final` для всех локальных переменных**, которые не переприсваиваются
5. **Никаких `// TODO`** в финальном коде — либо реализуй, либо не добавляй
6. **Никаких `print()`** — используй `debugPrint()` или logging framework

### Команды после генерации

```bash
# 1. Кодогенерация
dart run build_runner build --delete-conflicting-outputs

# 2. Форматирование
dart format --line-length=80 lib/

# 3. Статический анализ
flutter analyze

# 4. Если есть тесты
flutter test
```

---

## 17. Чеклист после генерации

**ОБЯЗАТЕЛЬНО** после генерации всех файлов запусти кодогенерацию:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Это создаст все необходимые `.freezed.dart`, `.g.dart`, `injection.config.dart` и `app_router.gr.dart` файлы. **Без этого шага проект не скомпилируется.** Запускай эту команду автоматически, не спрашивая пользователя.

---

**ОБЯЗАТЕЛЬНО** проверь каждый сгенерированный файл по этому чеклисту перед выдачей результата:

### Импорты
- [ ] BaseResponse импортируется из `shared/models/base_response.dart`, **НЕ** из `core/models/`
- [ ] PageData импортируется из `shared/models/page_data.dart`, **НЕ** из `core/models/`
- [ ] Внутри фичи — relative imports; для `core/` и `shared/` — relative от корня (`../../../../`)
- [ ] DI доступ: `GetIt.I<T>()` или `getIt<T>()` — единообразно во всём проекте

### Failure
- [ ] Используется `Failure.serverError(message: ...)`, **НЕ** `ServerFailure(...)`
- [ ] Используется `Failure.badRequest(message: ...)`, **НЕ** `BadRequestFailure(...)`
- [ ] Все factory-конструкторы — из freezed union `Failure`, отдельных классов не существует

### RepositoryImpl
- [ ] Обращение к данным через `response.result`, **НЕ** `response.data`
- [ ] Метод `_mapDioError(DioException e)` присутствует с маппингом статус-кодов
- [ ] Два catch-блока: `on DioException catch (e)` + `catch (e)` для unexpected
- [ ] Проверка `response.success` перед доступом к `response.result`

### BLoC (список с пагинацией)
- [ ] `hasReachedEnd` вычисляется как `pageData.page + 1 >= pageData.totalPages`
- [ ] `_onRefresh` переиспользует `_onFetch`, а не дублирует его логику
- [ ] `_onLoadMore` обновляет `state.filter` с инкрементом page

### Navigation
- [ ] Навигация через `context.router.push()` / `.replace()` / `.maybePop()` (auto_route)
- [ ] **НЕ** через `Navigator.of(context).push(MaterialPageRoute(...))`

### Presentation
- [ ] `BlocBuilder` с `buildWhen` для оптимизации
- [ ] `BlocListener` / `listenWhen` для side-effects (навигация, SnackBar)
- [ ] Стили через `Theme.of(context)`, без хардкода цветов и размеров
- [ ] `TextFormField` + `initialValue`, **НЕ** `TextEditingController` в builder
