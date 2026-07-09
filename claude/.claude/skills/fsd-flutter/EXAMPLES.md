# fsd-flutter — Примеры

> Шаблоны per-feature файлов (entity, model, repository, usecases, BLoC, тесты) — в [templates/](./templates/).
> Здесь — только уникальные UI-паттерны и нестандартные кейсы.

---

## Пример 1: List Page с infinite scroll

Запрос: "Создай страницу списка Product с пагинацией"

```dart
// lib/features/product/presentation/pages/product_list_page.dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/di/injection.dart';
import '../../../../app/router/app_router.gr.dart';
import '../../../../shared/widgets/app_empty_widget.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../bloc/product_list_bloc.dart';
import '../bloc/product_list_event.dart';
import '../bloc/product_list_state.dart';
import '../widgets/product_card.dart';

@RoutePage()
class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProductListBloc>()..add(const ProductListEvent.fetch()),
      child: const _ProductListView(),
    );
  }
}

class _ProductListView extends StatelessWidget {
  const _ProductListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Продукты'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final created = await context.router.push<bool>(const ProductFormRoute());
              if (created == true && context.mounted) {
                context.read<ProductListBloc>().add(const ProductListEvent.refresh());
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<ProductListBloc, ProductListState>(
        builder: (context, state) {
          if (state.isLoading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null && state.items.isEmpty) {
            return AppErrorWidget(
              message: state.errorMessage!,
              onRetry: () => context.read<ProductListBloc>().add(const ProductListEvent.fetch()),
            );
          }

          if (state.items.isEmpty) {
            return const AppEmptyWidget(message: 'Нет продуктов');
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ProductListBloc>().add(const ProductListEvent.refresh());
            },
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollEndNotification &&
                    notification.metrics.pixels >=
                        notification.metrics.maxScrollExtent - 200) {
                  context.read<ProductListBloc>().add(const ProductListEvent.loadMore());
                }
                return false;
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.items.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final product = state.items[index];
                  return ProductCard(
                    product: product,
                    onTap: () => context.router.push(ProductDetailRoute(id: product.id)),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
```

### Product Card Widget

```dart
// lib/features/product/presentation/widgets/product_card.dart
import 'package:flutter/material.dart';
import '../../domain/entities/product_entity.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(product.name),
        subtitle: Text('${product.price} ₸'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
```

---

## Пример 2: Detail Page с удалением

Запрос: "Создай детальную страницу Product с кнопками редактирования и удаления"

```dart
// lib/features/product/presentation/pages/product_detail_page.dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/di/injection.dart';
import '../../../../app/router/app_router.gr.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/app_loading_widget.dart';
import '../../domain/entities/product_entity.dart';
import '../bloc/product_detail_bloc.dart';
import '../bloc/product_detail_event.dart';
import '../bloc/product_detail_state.dart';

@RoutePage()
class ProductDetailPage extends StatelessWidget {
  final int id;

  const ProductDetailPage({super.key, @PathParam('id') required this.id});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProductDetailBloc>()..add(ProductDetailEvent.load(id)),
      child: _ProductDetailView(id: id),
    );
  }
}

class _ProductDetailView extends StatelessWidget {
  final int id;

  const _ProductDetailView({required this.id});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductDetailBloc, ProductDetailState>(
      listener: (context, state) {
        state.mapOrNull(
          deleted: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Продукт удалён')),
            );
            context.router.maybePop(true);
          },
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Продукт'),
          actions: [
            BlocBuilder<ProductDetailBloc, ProductDetailState>(
              builder: (context, state) {
                return state.maybeMap(
                  loaded: (s) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          final updated = await context.router.push<bool>(
                            ProductFormRoute(product: s.product),
                          );
                          if (updated == true && context.mounted) {
                            context.read<ProductDetailBloc>().add(ProductDetailEvent.load(id));
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _showDeleteDialog(context, id),
                      ),
                    ],
                  ),
                  orElse: () => const SizedBox.shrink(),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<ProductDetailBloc, ProductDetailState>(
          builder: (context, state) {
            return state.map(
              initial: (_) => const SizedBox.shrink(),
              loading: (_) => const AppLoadingWidget(),
              loaded: (s) => _buildContent(context, s.product),
              deleted: (_) => const SizedBox.shrink(),
              error: (s) => AppErrorWidget(
                message: s.message,
                onRetry: () => context.read<ProductDetailBloc>().add(ProductDetailEvent.load(id)),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProductEntity product) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(product.name, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('${product.price} ₸', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Text('Категория: ${product.categoryId}'),
          const SizedBox(height: 8),
          Text('Создан: ${product.createdAt}'),
          Text('Обновлён: ${product.updatedAt}'),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить продукт?'),
        content: const Text('Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<ProductDetailBloc>().add(ProductDetailEvent.delete(id));
            },
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}
```

---

## Пример 3: Фильтр по статусу (FilterChip)

Запрос: "Добавь фильтрацию заказов по статусу"

### Order List BLoC (расширение — дополнительный event filterByStatus)

```dart
// В order_list_event.dart добавить:
const factory OrderListEvent.filterByStatus(String? status) = _FilterByStatus;

// В order_list_bloc.dart добавить обработчик:
Future<void> _onFilterByStatus(String? status, Emitter<OrderListState> emit) async {
  final newFilter = state.filter.copyWith(page: 0, status: status);
  emit(state.copyWith(filter: newFilter, items: [], hasReachedEnd: false));
  await _onFetch(emit);
}
```

### Виджет фильтра

```dart
// lib/features/order/presentation/widgets/order_filter_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/order_list_bloc.dart';
import '../bloc/order_list_event.dart';
import '../bloc/order_list_state.dart';

class OrderFilterWidget extends StatelessWidget {
  const OrderFilterWidget({super.key});

  static const _statuses = [
    (null, 'Все'),
    ('NEW', 'Новые'),
    ('IN_PROGRESS', 'В работе'),
    ('COMPLETED', 'Завершённые'),
    ('CANCELLED', 'Отменённые'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderListBloc, OrderListState>(
      buildWhen: (prev, curr) => prev.filter.status != curr.filter.status,
      builder: (context, state) {
        return SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _statuses.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final (value, label) = _statuses[index];
              final isSelected = state.filter.status == value;

              return FilterChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (_) {
                  context.read<OrderListBloc>().add(
                        OrderListEvent.filterByStatus(value),
                      );
                },
              );
            },
          ),
        );
      },
    );
  }
}
```

---

## Пример 4: Formz Inputs (валидация с regex)

Запрос: "Создай форму с валидацией email и телефона"

### EmailInput

```dart
// lib/features/user/presentation/cubit/inputs/email_input.dart
import 'package:formz/formz.dart';

enum EmailValidationError { empty, invalid }

class EmailInput extends FormzInput<String, EmailValidationError> {
  const EmailInput.pure() : super.pure('');
  const EmailInput.dirty([super.value = '']) : super.dirty();

  static final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');

  @override
  EmailValidationError? validator(String value) {
    if (value.isEmpty) return EmailValidationError.empty;
    if (!_emailRegex.hasMatch(value)) return EmailValidationError.invalid;
    return null;
  }
}

extension EmailValidationErrorX on EmailValidationError {
  String get message => switch (this) {
        EmailValidationError.empty => 'Email обязателен',
        EmailValidationError.invalid => 'Некорректный email',
      };
}
```

### PhoneInput

```dart
// lib/features/user/presentation/cubit/inputs/phone_input.dart
import 'package:formz/formz.dart';

enum PhoneValidationError { empty, invalid }

class PhoneInput extends FormzInput<String, PhoneValidationError> {
  const PhoneInput.pure() : super.pure('');
  const PhoneInput.dirty([super.value = '']) : super.dirty();

  static final _phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');

  @override
  PhoneValidationError? validator(String value) {
    if (value.isEmpty) return PhoneValidationError.empty;
    if (!_phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
      return PhoneValidationError.invalid;
    }
    return null;
  }
}

extension PhoneValidationErrorX on PhoneValidationError {
  String get message => switch (this) {
        PhoneValidationError.empty => 'Телефон обязателен',
        PhoneValidationError.invalid => 'Некорректный номер',
      };
}
```

---

## Пример 5: Form Page с formz (создание/редактирование)

Запрос: "Создай форму создания/редактирования User"

### Form Cubit

```dart
// lib/features/user/presentation/cubit/user_form_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/create_user.dart';
import '../../domain/usecases/update_user.dart';
import '../../domain/params/create_user_params.dart';
import '../../domain/params/update_user_params.dart';
import 'inputs/email_input.dart';
import 'inputs/phone_input.dart';

part 'user_form_cubit.freezed.dart';
part 'user_form_state.dart';

@injectable
class UserFormCubit extends Cubit<UserFormState> {
  final CreateUser _createUser;
  final UpdateUser _updateUser;

  UserFormCubit(this._createUser, this._updateUser)
      : super(const UserFormState());

  void initForEdit(UserEntity user) {
    emit(state.copyWith(
      isEditMode: true,
      editId: user.id,
      firstName: user.firstName,
      lastName: user.lastName,
      email: EmailInput.dirty(user.email),
      phone: PhoneInput.dirty(user.phone),
    ));
  }

  void firstNameChanged(String value) => emit(state.copyWith(firstName: value));
  void lastNameChanged(String value) => emit(state.copyWith(lastName: value));
  void emailChanged(String value) => emit(state.copyWith(email: EmailInput.dirty(value)));
  void phoneChanged(String value) => emit(state.copyWith(phone: PhoneInput.dirty(value)));

  Future<void> submit() async {
    final email = EmailInput.dirty(state.email.value);
    final phone = PhoneInput.dirty(state.phone.value);

    emit(state.copyWith(email: email, phone: phone));

    if (!Formz.validate([email, phone]) || state.firstName.trim().isEmpty || state.lastName.trim().isEmpty) {
      return;
    }

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    final result = state.isEditMode
        ? await _updateUser(UpdateUserParams(
            id: state.editId!,
            firstName: state.firstName,
            lastName: state.lastName,
            email: state.email.value,
            phone: state.phone.value,
          ))
        : await _createUser(CreateUserParams(
            firstName: state.firstName,
            lastName: state.lastName,
            email: state.email.value,
            phone: state.phone.value,
          ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: FormzSubmissionStatus.success)),
    );
  }
}
```

### Form State

```dart
// lib/features/user/presentation/cubit/user_form_state.dart
part of 'user_form_cubit.dart';

@freezed
class UserFormState with _$UserFormState {
  const factory UserFormState({
    @Default(false) bool isEditMode,
    int? editId,
    @Default('') String firstName,
    @Default('') String lastName,
    @Default(EmailInput.pure()) EmailInput email,
    @Default(PhoneInput.pure()) PhoneInput phone,
    @Default(FormzSubmissionStatus.initial) FormzSubmissionStatus status,
    String? errorMessage,
  }) = _UserFormState;
}
```

### Form Page

```dart
// lib/features/user/presentation/pages/user_form_page.dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import '../../../../app/di/injection.dart';
import '../../domain/entities/user_entity.dart';
import '../cubit/user_form_cubit.dart';
import '../cubit/inputs/email_input.dart';
import '../cubit/inputs/phone_input.dart';

@RoutePage()
class UserFormPage extends StatelessWidget {
  final UserEntity? user;

  const UserFormPage({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<UserFormCubit>();
        if (user != null) cubit.initForEdit(user!);
        return cubit;
      },
      child: const _UserFormView(),
    );
  }
}

class _UserFormView extends StatelessWidget {
  const _UserFormView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserFormCubit, UserFormState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == FormzSubmissionStatus.success) {
          context.router.maybePop(true);
        } else if (state.status == FormzSubmissionStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Ошибка')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<UserFormCubit, UserFormState>(
            buildWhen: (prev, curr) => prev.isEditMode != curr.isEditMode,
            builder: (context, state) {
              return Text(state.isEditMode ? 'Редактирование' : 'Создание');
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              BlocBuilder<UserFormCubit, UserFormState>(
                buildWhen: (prev, curr) => prev.firstName != curr.firstName,
                builder: (context, state) {
                  return TextFormField(
                    initialValue: state.firstName,
                    decoration: InputDecoration(
                      labelText: 'Имя',
                      errorText: state.firstName.trim().isEmpty && state.status.isFailure
                          ? 'Имя обязательно'
                          : null,
                    ),
                    onChanged: context.read<UserFormCubit>().firstNameChanged,
                  );
                },
              ),
              const SizedBox(height: 16),
              BlocBuilder<UserFormCubit, UserFormState>(
                buildWhen: (prev, curr) => prev.lastName != curr.lastName,
                builder: (context, state) {
                  return TextFormField(
                    initialValue: state.lastName,
                    decoration: const InputDecoration(labelText: 'Фамилия'),
                    onChanged: context.read<UserFormCubit>().lastNameChanged,
                  );
                },
              ),
              const SizedBox(height: 16),
              BlocBuilder<UserFormCubit, UserFormState>(
                buildWhen: (prev, curr) => prev.email != curr.email,
                builder: (context, state) {
                  return TextFormField(
                    initialValue: state.email.value,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      errorText: state.email.displayError?.message,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: context.read<UserFormCubit>().emailChanged,
                  );
                },
              ),
              const SizedBox(height: 16),
              BlocBuilder<UserFormCubit, UserFormState>(
                buildWhen: (prev, curr) => prev.phone != curr.phone,
                builder: (context, state) {
                  return TextFormField(
                    initialValue: state.phone.value,
                    decoration: InputDecoration(
                      labelText: 'Телефон',
                      errorText: state.phone.displayError?.message,
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: context.read<UserFormCubit>().phoneChanged,
                  );
                },
              ),
              const SizedBox(height: 32),
              BlocBuilder<UserFormCubit, UserFormState>(
                buildWhen: (prev, curr) => prev.status != curr.status,
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state.status == FormzSubmissionStatus.inProgress
                        ? null
                        : context.read<UserFormCubit>().submit,
                    child: state.status == FormzSubmissionStatus.inProgress
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(state.isEditMode ? 'Сохранить' : 'Создать'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Пример 6: Nested Navigation (Tab-based)

Запрос: "Добавь навигацию с табами"

### Router Config (nested)

```dart
@AutoRouterConfig()
@singleton
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: LoginRoute.page, path: '/login'),
        AutoRoute(
          page: MainRoute.page,
          path: '/',
          initial: true,
          children: [
            AutoRoute(page: ProductListRoute.page, path: 'products'),
            AutoRoute(page: OrderListRoute.page, path: 'orders'),
            AutoRoute(page: ProfileRoute.page, path: 'profile'),
          ],
        ),
        AutoRoute(page: ProductDetailRoute.page, path: '/products/:id'),
        AutoRoute(page: ProductFormRoute.page, path: '/products/form'),
      ];
}
```

### Main Page с BottomNavigation

```dart
@RoutePage()
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      routes: const [
        ProductListRoute(),
        OrderListRoute(),
        ProfileRoute(),
      ],
      bottomNavigationBuilder: (context, tabsRouter) {
        return BottomNavigationBar(
          currentIndex: tabsRouter.activeIndex,
          onTap: tabsRouter.setActiveIndex,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Продукты'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Заказы'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
          ],
        );
      },
    );
  }
}
```

---

## Пример 7: Связанные фичи (Order → Product)

Запрос: "Создай фичу Order со связью на Product"

### Order Entity (со вложенным Product)

```dart
// lib/features/order/domain/entities/order_entity.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../product/domain/entities/product_entity.dart';

part 'order_entity.freezed.dart';

@freezed
class OrderEntity with _$OrderEntity {
  const factory OrderEntity({
    required int id,
    required String status,
    required int quantity,
    required double totalPrice,
    required ProductEntity product,
    required String createdAt,
    required String updatedAt,
  }) = _OrderEntity;
}
```

### Order Model (со вложенным ProductModel)

```dart
// lib/features/order/data/models/order_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../product/data/models/product_model.dart';
import '../../domain/entities/order_entity.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

@freezed
class OrderModel with _$OrderModel {
  const OrderModel._();

  const factory OrderModel({
    required int id,
    required String status,
    required int quantity,
    required double totalPrice,
    required ProductModel product,
    required String createdAt,
    required String updatedAt,
  }) = _OrderModel;

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  OrderEntity toEntity() => OrderEntity(
        id: id,
        status: status,
        quantity: quantity,
        totalPrice: totalPrice,
        product: product.toEntity(),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
```

### Create Order Request (ссылка по ID)

```dart
// lib/features/order/data/models/create_order_request.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_order_request.freezed.dart';
part 'create_order_request.g.dart';

@freezed
class CreateOrderRequest with _$CreateOrderRequest {
  const factory CreateOrderRequest({
    required int productId,
    required int quantity,
  }) = _CreateOrderRequest;

  factory CreateOrderRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderRequestFromJson(json);
}
```

**Правило связей:**
- В Response бэкенд возвращает вложенные объекты целиком (Order содержит Product).
- В Request на создание/обновление передаётся только ID связанной сущности (`productId`).
- Model импортирует связанные Model'и для `toEntity()`.
- Entity импортирует связанные Entity (это допустимо в domain).
