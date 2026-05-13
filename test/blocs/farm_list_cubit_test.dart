import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:feddan/domain/entities/farm_entity.dart';
import 'package:feddan/domain/repositories/auth_repository.dart';
import 'package:feddan/domain/usecases/get_cached_farms_usecase.dart';
import 'package:feddan/domain/usecases/get_farms_usecase.dart';
import 'package:feddan/presentation/blocs/farm_list/farm_list_cubit.dart';
import 'package:feddan/presentation/blocs/farm_list/farm_list_state.dart';

class MockGetFarmsUseCase extends Mock implements GetFarmsUseCase {}
class MockGetCachedFarmsUseCase extends Mock implements GetCachedFarmsUseCase {}
class MockAuthRepository extends Mock implements AuthRepository {}

final _farm = FarmEntity(
  id: 'f1',
  name: 'Nile Farm',
  latitude: 30.0,
  longitude: 31.0,
  cropTypes: const ['tomato'],
  plantingDate: DateTime(2025, 3, 1),
  ownerId: 'u1',
  createdAt: DateTime(2025, 3, 1),
);

void main() {
  late MockGetFarmsUseCase getFarms;
  late MockGetCachedFarmsUseCase getCachedFarms;
  late MockAuthRepository auth;

  setUp(() {
    getFarms = MockGetFarmsUseCase();
    getCachedFarms = MockGetCachedFarmsUseCase();
    auth = MockAuthRepository();
  });

  FarmListCubit build() => FarmListCubit(
        getFarms: getFarms,
        getCachedFarms: getCachedFarms,
        auth: auth,
      );

  group('loadFarms — online success', () {
    blocTest<FarmListCubit, FarmListState>(
      'emits loading then loaded with farms, fromCache = false',
      build: () {
        when(() => auth.currentUserId).thenReturn('u1');
        when(() => getFarms('u1')).thenAnswer((_) async => [_farm]);
        return build();
      },
      act: (c) => c.loadFarms(),
      expect: () => [
        isA<FarmListState>()
            .having((s) => s.status, 'status', FarmListStatus.loading),
        isA<FarmListState>()
            .having((s) => s.status, 'status', FarmListStatus.loaded)
            .having((s) => s.farms.length, 'farms.length', 1)
            .having((s) => s.fromCache, 'fromCache', false),
      ],
    );

    blocTest<FarmListCubit, FarmListState>(
      'emits loaded with empty list when user has no farms',
      build: () {
        when(() => auth.currentUserId).thenReturn('u1');
        when(() => getFarms('u1')).thenAnswer((_) async => []);
        return build();
      },
      act: (c) => c.loadFarms(),
      expect: () => [
        isA<FarmListState>()
            .having((s) => s.status, 'status', FarmListStatus.loading),
        isA<FarmListState>()
            .having((s) => s.status, 'status', FarmListStatus.loaded)
            .having((s) => s.farms, 'farms', isEmpty)
            .having((s) => s.hasFarms, 'hasFarms', false)
            .having((s) => s.fromCache, 'fromCache', false),
      ],
    );

    blocTest<FarmListCubit, FarmListState>(
      'farmIds getter returns only farms with non-null ids',
      build: () {
        when(() => auth.currentUserId).thenReturn('u1');
        when(() => getFarms('u1')).thenAnswer((_) async => [_farm]);
        return build();
      },
      act: (c) => c.loadFarms(),
      verify: (c) => expect(c.state.farmIds, ['f1']),
    );
  });

  group('loadFarms — offline fallback (H2)', () {
    blocTest<FarmListCubit, FarmListState>(
      'serves cached farms when Firestore fails, fromCache = true',
      build: () {
        when(() => auth.currentUserId).thenReturn('u1');
        when(() => getFarms('u1')).thenThrow(Exception('network error'));
        when(() => getCachedFarms('u1')).thenAnswer((_) async => [_farm]);
        return build();
      },
      act: (c) => c.loadFarms(),
      expect: () => [
        isA<FarmListState>()
            .having((s) => s.status, 'status', FarmListStatus.loading),
        isA<FarmListState>()
            .having((s) => s.status, 'status', FarmListStatus.loaded)
            .having((s) => s.farms.length, 'farms.length', 1)
            .having((s) => s.fromCache, 'fromCache', true),
      ],
    );

    blocTest<FarmListCubit, FarmListState>(
      'emits failure when Firestore fails AND no cache exists (M3)',
      build: () {
        when(() => auth.currentUserId).thenReturn('u1');
        when(() => getFarms('u1')).thenThrow(Exception('network error'));
        when(() => getCachedFarms('u1')).thenAnswer((_) async => null);
        return build();
      },
      act: (c) => c.loadFarms(),
      expect: () => [
        isA<FarmListState>()
            .having((s) => s.status, 'status', FarmListStatus.loading),
        isA<FarmListState>()
            .having((s) => s.status, 'status', FarmListStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );
  });

  group('loadFarms — auth', () {
    blocTest<FarmListCubit, FarmListState>(
      'emits failure immediately when user is not authenticated',
      build: () {
        when(() => auth.currentUserId).thenReturn(null);
        return build();
      },
      act: (c) => c.loadFarms(),
      expect: () => [
        isA<FarmListState>()
            .having((s) => s.status, 'status', FarmListStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );
  });

  group('refresh', () {
    blocTest<FarmListCubit, FarmListState>(
      'calls loadFarms again',
      build: () {
        when(() => auth.currentUserId).thenReturn('u1');
        when(() => getFarms('u1')).thenAnswer((_) async => [_farm]);
        return build();
      },
      act: (c) => c.refresh(),
      expect: () => [
        isA<FarmListState>()
            .having((s) => s.status, 'status', FarmListStatus.loading),
        isA<FarmListState>()
            .having((s) => s.status, 'status', FarmListStatus.loaded),
      ],
    );
  });
}
