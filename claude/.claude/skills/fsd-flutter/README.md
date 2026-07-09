# FSD Flutter Skill

A Claude Code skill that generates production-ready Flutter code following Clean Architecture + Feature-Sliced Design (FSD). Fully compatible with `fsd-backend` (Spring Boot). Just describe what you need — no architecture knowledge required.

---

## Installation / Установка

### English

1. Clone directly to your skills folder:
   ```bash
   git clone https://github.com/ilim-code/fsd-flutter.git ~/.claude/skills/fsd-flutter
   ```

2. Restart Claude Code to load the skill.

3. Copy `CLAUDE.md.template` to the root of your Flutter project:
   ```bash
   cp ~/.claude/skills/fsd-flutter/CLAUDE.md.template /path/to/your/project/CLAUDE.md
   ```

### Русский

1. Клонируйте в папку скиллов:
   ```bash
   git clone https://github.com/ilim-code/fsd-flutter.git ~/.claude/skills/fsd-flutter
   ```

2. Перезапустите Claude Code для загрузки скилла.

3. Скопируйте `CLAUDE.md.template` в корень вашего Flutter-проекта:
   ```bash
   cp ~/.claude/skills/fsd-flutter/CLAUDE.md.template /path/to/your/project/CLAUDE.md
   ```

---

## Usage / Использование

### English

Just describe what you need in plain language. The skill generates all necessary files following Clean Architecture + FSD best practices.

#### Create Features (Full CRUD)

```
Create a Product feature with name (String), price (double), categoryId (int)
```

```
Create an Order feature with items, total, status, and customerId
```

#### Lists & Pagination

```
Add a paginated list of Orders with status filter
```

```
Create an infinite scroll list for Products with search
```

#### Forms

```
Create a form for creating and editing User
```

```
Create a Product form with image upload and validation
```

#### Navigation & Tabs

```
Create tab-based navigation with Home, Orders, and Profile tabs
```

### Русский

Просто опишите что вам нужно на обычном языке. Скилл сгенерирует все необходимые файлы следуя Clean Architecture + FSD.

#### Создание фич (полный CRUD)

```
Создай фичу Product с полями name (String), price (double), categoryId (int)
```

```
Создай фичу Order с полями items, total, status и customerId
```

#### Списки и пагинация

```
Добавь пагинированный список Orders с фильтрацией по статусу
```

```
Создай infinite scroll список для Products с поиском
```

#### Формы

```
Создай форму создания/редактирования User
```

```
Создай форму Product с загрузкой изображения и валидацией
```

#### Навигация и табы

```
Создай tab-навигацию с вкладками Home, Orders и Profile
```

---

## What Gets Generated / Что генерируется

### English

When you create a feature (e.g., "Create a Product feature with name and price"), you get:

```
lib/features/product/
├── domain/
│   ├── entities/
│   │   └── product_entity.dart          # Freezed Entity
│   ├── params/
│   │   ├── product_filter_params.dart   # Filter params (page, size, search...)
│   │   ├── product_create_params.dart   # Create params
│   │   └── product_update_params.dart   # Update params
│   ├── repositories/
│   │   └── product_repository.dart      # Abstract Repository
│   └── usecases/
│       ├── get_product_by_id.dart
│       ├── get_products.dart            # POST /filter
│       ├── create_product.dart
│       ├── update_product.dart
│       └── delete_product.dart
├── data/
│   ├── models/
│   │   ├── product_model.dart           # Model + fromJson + toEntity()
│   │   ├── product_create_request.dart
│   │   ├── product_update_request.dart
│   │   └── product_filter_request.dart
│   ├── datasources/
│   │   └── product_remote_ds.dart       # Retrofit @RestApi
│   └── repositories/
│       └── product_repository_impl.dart # params→request + _mapDioError
└── presentation/
    ├── list/
    │   ├── product_list_bloc.dart
    │   ├── product_list_event.dart
    │   └── product_list_state.dart
    ├── detail/
    │   ├── product_detail_bloc.dart
    │   ├── product_detail_event.dart
    │   └── product_detail_state.dart
    └── pages/
        ├── product_list_page.dart
        ├── product_detail_page.dart
        └── product_form_page.dart
```

### Русский

Когда вы создаёте фичу (например, "Создай фичу Product с name и price"), вы получаете:

```
lib/features/product/
├── domain/          # Бизнес-логика (Entity, Params, Repository, UseCases)
├── data/            # Реализация (Model, Request DTO, RemoteDs, RepositoryImpl)
└── presentation/    # UI (BLoC/Cubit, Pages, Widgets)
```

Полная структура — 20+ файлов с полным CRUD, пагинацией, обработкой ошибок и DI.

---

## Technology Stack / Технологический стек

| Category / Категория | Package / Пакет |
|---------------------|-----------------|
| State Management | `flutter_bloc` (BLoC + Cubit) |
| HTTP Client | `dio` |
| API Layer | `retrofit` |
| Models / DTOs | `freezed` + `json_serializable` |
| Dependency Injection | `get_it` + `injectable` |
| Navigation | `auto_route` |
| Error Handling | `fpdart` (Either<Failure, T>) |
| Forms | `formz` |
| Responsive | `flutter_screenutil` |
| Code Generation | `build_runner` |
| Testing | `bloc_test` + `mocktail` |

---

## Backend Compatibility / Совместимость с бэкендом

### English

The skill generates models and API clients fully compatible with `fsd-backend` (Spring Boot):

- `BaseResponse<T>` — wraps all API responses (field: `result`, not `data`)
- `PageData<T>` — pagination via `POST /filter`
- Standard entity fields: `id`, `createdAt`, `updatedAt`
- HTTP error mapping: status codes → typed `Failure` (Freezed union)
  - 400 → `Failure.badRequest()`
  - 401 → `Failure.unauthorized()`
  - 403 → `Failure.forbidden()`
  - 404 → `Failure.notFound()`
  - 409 → `Failure.conflict()`
  - 5xx → `Failure.serverError()`

### Русский

Скилл генерирует модели и API-клиенты, полностью совместимые с форматом `fsd-backend` (Spring Boot):

- `BaseResponse<T>` — обёртка всех ответов (поле: `result`, не `data`)
- `PageData<T>` — пагинация через `POST /filter`
- Стандартные поля сущностей: `id`, `createdAt`, `updatedAt`
- Маппинг HTTP-ошибок: коды → типизированный `Failure` (Freezed union)

---

## Architecture / Архитектура

This skill follows **Clean Architecture + Feature-Sliced Design**:

```
lib/
├── app/                  # App configuration, DI setup, routing
├── features/             # Feature modules (each with domain/data/presentation)
│   └── [feature]/
│       ├── domain/       # Entities, Params, Repository (abstract), UseCases
│       ├── data/         # Models, Request DTOs, RemoteDs, RepositoryImpl
│       └── presentation/ # BLoC/Cubit, Pages, Widgets
├── shared/
│   └── models/           # BaseResponse, PageData
└── core/
    ├── di/               # get_it + injectable setup
    ├── network/          # Dio configuration
    └── navigation/       # auto_route setup
```

**Dependency Rule:** `presentation → domain ← data`
- Domain knows nothing about data or presentation
- Data implements domain contracts
- Presentation uses domain through DI

**BLoC vs Cubit:**
| Use Case | Pattern |
|----------|---------|
| Lists, pagination, complex flows | **BLoC** (Events + States) |
| Forms, toggles, simple actions | **Cubit** (methods) |

---

## Examples / Примеры

### Example 1: Feature with Infinite Scroll

**English:**
```
Create a Product feature with:
- name (String)
- price (double)
- categoryId (int)
- imageUrl (String)
Add a paginated list with infinite scroll and search
```

**Русский:**
```
Создай фичу Product с полями:
- name (String)
- price (double)
- categoryId (int)
- imageUrl (String)
Добавь пагинированный список с infinite scroll и поиском
```

### Example 2: Form with Validation

**English:**
```
Create a User form with email validation and phone formatting using formz
```

**Русский:**
```
Создай форму User с валидацией email и форматированием телефона через formz
```

### Example 3: Related Features

**English:**
```
Create an Order feature linked to Product. Order has a list of products with quantities.
```

**Русский:**
```
Создай фичу Order связанную с Product. Order содержит список продуктов с количеством.
```

See [EXAMPLES.md](./EXAMPLES.md) for 7 complete implementation examples with full code.

---

## Project Setup / Настройка проекта

### English

1. **Install dependencies** in `pubspec.yaml`:
   ```yaml
   dependencies:
     flutter_bloc: ^8.1.0
     dio: ^5.0.0
     retrofit: ^4.0.0
     freezed_annotation: ^2.4.0
     json_annotation: ^4.8.0
     get_it: ^7.6.0
     injectable: ^2.3.0
     auto_route: ^7.8.0
     fpdart: ^1.1.0
     formz: ^0.7.0
     flutter_screenutil: ^5.9.0

   dev_dependencies:
     build_runner: ^2.4.0
     freezed: ^2.4.0
     json_serializable: ^6.7.0
     retrofit_generator: ^8.0.0
     injectable_generator: ^2.4.0
     auto_route_generator: ^7.3.0
     bloc_test: ^9.1.0
     mocktail: ^1.0.0
   ```

2. **Copy project config:**
   ```bash
   cp ~/.claude/skills/fsd-flutter/CLAUDE.md.template /path/to/your/project/CLAUDE.md
   ```

3. **Run code generation** after generating files:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

### Русский

1. **Установите зависимости** в `pubspec.yaml` (см. выше)

2. **Скопируйте конфиг проекта:**
   ```bash
   cp ~/.claude/skills/fsd-flutter/CLAUDE.md.template /path/to/your/project/CLAUDE.md
   ```

3. **Запустите кодогенерацию** после генерации файлов:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

---

## Tips / Советы

### English

1. **Be specific about field types** — "Create User with name (String), age (int), isActive (bool)"
2. **Mention relationships** — "Order contains a list of Products"
3. **Specify UI patterns** — "Add infinite scroll" or "Use tabs for navigation"
4. **Request partial generation** — "Create only the domain layer for Product"

### Русский

1. **Указывайте типы полей** — "Создай User с name (String), age (int), isActive (bool)"
2. **Упоминайте связи** — "Order содержит список Products"
3. **Указывайте UI паттерны** — "Добавь infinite scroll" или "Используй табы для навигации"
4. **Запрашивайте частичную генерацию** — "Создай только domain слой для Product"

---

## Files / Файлы

| File / Файл | Purpose / Назначение |
|-------------|---------------------|
| `SKILL.md` | Main skill file — all patterns and rules / Главный файл скилла |
| `EXAMPLES.md` | 7 practical implementation examples / Практические примеры |
| `CLAUDE.md.template` | Template for project-level CLAUDE.md / Шаблон конфига проекта |
| `templates/` | 27 Dart code templates / Шаблоны кода |

---

## License / Лицензия

MIT
