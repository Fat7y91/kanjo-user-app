import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:heraj/core/errors/failure.dart';
import 'package:heraj/features/bundle_order/data/models/bundle_order_model.dart';
import 'package:heraj/features/bundle_order/domain/entities/submit_bundle_params.dart';
import 'package:heraj/features/bundle_order/domain/repo/bundle_order_repo.dart';
import 'package:heraj/features/bundle_order/domain/use_case/add_my_cart_to_bundle_use_case.dart';
import 'package:heraj/features/bundle_order/domain/use_case/create_bundle_from_cart_use_case.dart';
import 'package:heraj/features/bundle_order/domain/use_case/list_my_bundle_orders_use_case.dart';
import 'package:heraj/features/bundle_order/domain/use_case/remove_my_bundle_item_use_case.dart';
import 'package:heraj/features/bundle_order/domain/use_case/show_bundle_by_code_use_case.dart';
import 'package:heraj/features/bundle_order/domain/use_case/submit_bundle_use_case.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'bundle_order_use_cases_test.mocks.dart';

@GenerateMocks([BundleOrderRepo])
void main() {
  late MockBundleOrderRepo mockRepo;
  late ListMyBundleOrdersUseCase listMyBundleOrders;
  late CreateBundleFromCartUseCase createBundleFromCart;
  late ShowBundleByCodeUseCase showBundleByCode;
  late AddMyCartToBundleUseCase addMyCartToBundle;
  late RemoveMyBundleItemUseCase removeMyBundleItem;
  late SubmitBundleUseCase submitBundle;

  const sample = BundleOrderModel(
    id: 2,
    code: 'JXP201',
    status: 'collecting',
    isHost: true,
  );

  setUpAll(() {
    provideDummy<Either<Failure, List<BundleOrderModel>>>(
      Left(GeneralError('dummy')),
    );
    provideDummy<Either<Failure, BundleOrderModel>>(
      Left(GeneralError('dummy')),
    );
    provideDummy<Either<Failure, bool>>(
      Left(GeneralError('dummy')),
    );
  });

  setUp(() {
    mockRepo = MockBundleOrderRepo();
    listMyBundleOrders = ListMyBundleOrdersUseCase(bundleOrderRepo: mockRepo);
    createBundleFromCart =
        CreateBundleFromCartUseCase(bundleOrderRepo: mockRepo);
    showBundleByCode = ShowBundleByCodeUseCase(bundleOrderRepo: mockRepo);
    addMyCartToBundle = AddMyCartToBundleUseCase(bundleOrderRepo: mockRepo);
    removeMyBundleItem = RemoveMyBundleItemUseCase(bundleOrderRepo: mockRepo);
    submitBundle = SubmitBundleUseCase(bundleOrderRepo: mockRepo);
  });

  group('BundleOrder use cases (TDD / Mockito)', () {
    test('listMyBundleOrders returns my bundles', () async {
      when(mockRepo.listMyBundleOrders()).thenAnswer(
        (_) async => const Right([sample]),
      );

      final result = await listMyBundleOrders();

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('expected listMyBundleOrders to succeed'),
        (bundles) {
          expect(bundles, isA<List<BundleOrderModel>>());
          expect(bundles.first.code, 'JXP201');
        },
      );
      verify(mockRepo.listMyBundleOrders()).called(1);
      verifyNoMoreInteractions(mockRepo);
    });

    test('createBundleFromCart creates a bundle from cart', () async {
      when(mockRepo.createBundleFromCart(notes: null)).thenAnswer(
        (_) async => const Right(sample),
      );

      final result = await createBundleFromCart(
        const CreateBundleFromCartParams(),
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('expected createBundleFromCart to succeed'),
        (bundle) {
          expect(bundle.code, isNotEmpty);
          expect(bundle.id, greaterThan(0));
        },
      );
      verify(mockRepo.createBundleFromCart(notes: null)).called(1);
      verifyNoMoreInteractions(mockRepo);
    });

    test('showBundleByCode returns bundle details', () async {
      const code = 'JXP201';
      when(mockRepo.showBundleByCode(code)).thenAnswer(
        (_) async => const Right(sample),
      );

      final result = await showBundleByCode(code);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('expected showBundleByCode to succeed'),
        (bundle) => expect(bundle.code, code),
      );
      verify(mockRepo.showBundleByCode(code)).called(1);
      verifyNoMoreInteractions(mockRepo);
    });

    test('addMyCartToBundle adds current cart into bundle', () async {
      const code = 'JXP201';
      when(mockRepo.addMyCartToBundle(code)).thenAnswer(
        (_) async => const Right(sample),
      );

      final result = await addMyCartToBundle(code);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('expected addMyCartToBundle to succeed'),
        (bundle) => expect(bundle.code, code),
      );
      verify(mockRepo.addMyCartToBundle(code)).called(1);
      verifyNoMoreInteractions(mockRepo);
    });

    test('removeMyBundleItem removes an item from bundle', () async {
      const params = RemoveBundleItemParams(
        bundleCode: 'JXP201',
        bundleItemId: 1,
      );
      when(
        mockRepo.removeMyBundleItem(
          bundleCode: params.bundleCode,
          bundleItemId: params.bundleItemId,
        ),
      ).thenAnswer((_) async => const Right(true));

      final result = await removeMyBundleItem(params);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('expected removeMyBundleItem to succeed'),
        (ok) => expect(ok, isTrue),
      );
      verify(
        mockRepo.removeMyBundleItem(
          bundleCode: params.bundleCode,
          bundleItemId: params.bundleItemId,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepo);
    });

    test('submitBundle submits bundle as host', () async {
      const params = SubmitBundleParams(code: 'JXP201', addressId: 1);
      when(mockRepo.submitBundle(params)).thenAnswer(
        (_) async => const Right(sample),
      );

      final result = await submitBundle(params);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('expected submitBundle to succeed'),
        (bundle) {
          expect(bundle.code, params.code);
          expect(bundle.status, isNotEmpty);
        },
      );
      verify(mockRepo.submitBundle(params)).called(1);
      verifyNoMoreInteractions(mockRepo);
    });
  });
}
