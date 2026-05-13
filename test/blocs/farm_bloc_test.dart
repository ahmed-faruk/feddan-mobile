import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:feddan/domain/entities/farm_entity.dart';
import 'package:feddan/domain/repositories/farm_repository.dart';
import 'package:feddan/domain/usecases/create_farm_usecase.dart';
import 'package:feddan/domain/usecases/delete_farm_usecase.dart';
import 'package:feddan/domain/usecases/update_farm_usecase.dart';
import 'package:feddan/presentation/blocs/farm/farm_bloc.dart';

class MockCreateFarmUseCase extends Mock implements CreateFarmUseCase {}
class MockUpdateFarmUseCase extends Mock implements UpdateFarmUseCase {}
class MockDeleteFarmUseCase extends Mock implements DeleteFarmUseCase {}

final _stubFarm = FarmEntity(
  id: 'farm-1',
  name: 'Test Farm',
  latitude: 30.0,
  longitude: 31.0,
  cropTypes: const ['tomato'],
  plantingDate: DateTime(2025, 3, 1),
  ownerId: 'user-1',
  createdAt: DateTime(2025, 3, 1),
);

void main() {
  late MockCreateFarmUseCase createFarm;
  late MockUpdateFarmUseCase updateFarm;
  late MockDeleteFarmUseCase deleteFarm;

  setUpAll(() {
    registerFallbackValue(
      CreateFarmParams(
        name: 'x',
        latitude: 0,
        longitude: 0,
        cropTypes: const [],
        plantingDate: DateTime(2025),
      ),
    );
  });

  setUp(() {
    createFarm = MockCreateFarmUseCase();
    updateFarm = MockUpdateFarmUseCase();
    deleteFarm = MockDeleteFarmUseCase();
  });

  FarmBloc build({FarmEntity? existing}) => FarmBloc(
        createFarm: createFarm,
        updateFarm: updateFarm,
        deleteFarm: deleteFarm,
        existingFarm: existing,
      );

  group('Create mode initial state', () {
    test('starts empty', () {
      final b = build();
      expect(b.state.name, '');
      expect(b.state.isEditMode, false);
      b.close();
    });
  });

  group('Edit mode initial state', () {
    test('pre-populated from existingFarm', () {
      final b = build(existing: _stubFarm);
      expect(b.state.name, 'Test Farm');
      expect(b.state.isEditMode, true);
      expect(b.state.editingFarmId, 'farm-1');
      expect(b.state.selectedCrops, ['tomato']);
      b.close();
    });
  });

  group('FarmNameChanged', () {
    blocTest<FarmBloc, FarmState>(
      'updates name in state',
      build: () => build(),
      act: (b) => b.add(const FarmNameChanged('My Farm')),
      expect: () => [
        isA<FarmState>().having((s) => s.name, 'name', 'My Farm'),
      ],
    );
  });

  group('FarmCropToggled', () {
    blocTest<FarmBloc, FarmState>(
      'adds crop when not selected',
      build: () => build(),
      act: (b) => b.add(const FarmCropToggled('tomato')),
      expect: () => [
        isA<FarmState>()
            .having((s) => s.selectedCrops, 'crops', contains('tomato')),
      ],
    );

    blocTest<FarmBloc, FarmState>(
      'removes crop when already selected',
      build: () => build(),
      seed: () => const FarmState(selectedCrops: ['tomato', 'potato']),
      act: (b) => b.add(const FarmCropToggled('tomato')),
      expect: () => [
        isA<FarmState>().having(
          (s) => s.selectedCrops,
          'crops',
          isNot(contains('tomato')),
        ),
      ],
    );
  });

  group('FarmPlantingDateChanged', () {
    blocTest<FarmBloc, FarmState>(
      'updates plantingDate',
      build: () => build(),
      act: (b) => b.add(FarmPlantingDateChanged(DateTime(2025, 4, 1))),
      expect: () => [
        isA<FarmState>().having(
          (s) => s.plantingDate,
          'plantingDate',
          DateTime(2025, 4, 1),
        ),
      ],
    );
  });

  group('FarmSaveRequested — create mode', () {
    blocTest<FarmBloc, FarmState>(
      'emits saving then success',
      build: () {
        when(() => createFarm(any())).thenAnswer((_) async => _stubFarm);
        return build();
      },
      seed: () => FarmState(
        name: 'Test',
        latitude: 30.0,
        longitude: 31.0,
        selectedCrops: const ['tomato'],
        plantingDate: DateTime(2025, 3, 1),
      ),
      act: (b) => b.add(const FarmSaveRequested()),
      expect: () => [
        isA<FarmState>()
            .having((s) => s.status, 'status', FarmStatus.saving),
        isA<FarmState>()
            .having((s) => s.status, 'status', FarmStatus.success),
      ],
    );

    blocTest<FarmBloc, FarmState>(
      'emits failure when use case throws',
      build: () {
        when(() => createFarm(any())).thenThrow(Exception('network'));
        return build();
      },
      seed: () => FarmState(
        name: 'Test',
        latitude: 30.0,
        longitude: 31.0,
        selectedCrops: const ['tomato'],
        plantingDate: DateTime(2025, 3, 1),
      ),
      act: (b) => b.add(const FarmSaveRequested()),
      expect: () => [
        isA<FarmState>()
            .having((s) => s.status, 'status', FarmStatus.saving),
        isA<FarmState>()
            .having((s) => s.status, 'status', FarmStatus.failure),
      ],
    );

    blocTest<FarmBloc, FarmState>(
      'does nothing when state is invalid',
      build: () => build(),
      // name is empty → invalid
      act: (b) => b.add(const FarmSaveRequested()),
      expect: () => <FarmState>[],
    );
  });

  group('FarmSaveRequested — edit mode', () {
    blocTest<FarmBloc, FarmState>(
      'calls updateFarm not createFarm',
      build: () {
        when(() => updateFarm(
              farmId: any(named: 'farmId'),
              params: any(named: 'params'),
            )).thenAnswer((_) async {});
        return build(existing: _stubFarm);
      },
      act: (b) => b.add(const FarmSaveRequested()),
      // seed is pre-populated from existingFarm, which is already valid
      expect: () => [
        isA<FarmState>()
            .having((s) => s.status, 'status', FarmStatus.saving),
        isA<FarmState>()
            .having((s) => s.status, 'status', FarmStatus.success),
      ],
      verify: (_) {
        verifyNever(() => createFarm(any()));
        verify(() => updateFarm(
              farmId: 'farm-1',
              params: any(named: 'params'),
            )).called(1);
      },
    );
  });

  group('FarmDeleteRequested', () {
    blocTest<FarmBloc, FarmState>(
      'emits deleting then deleted',
      build: () {
        when(() => deleteFarm(any())).thenAnswer((_) async {});
        return build(existing: _stubFarm);
      },
      act: (b) => b.add(const FarmDeleteRequested()),
      expect: () => [
        isA<FarmState>()
            .having((s) => s.status, 'status', FarmStatus.deleting),
        isA<FarmState>()
            .having((s) => s.status, 'status', FarmStatus.deleted),
      ],
    );

    blocTest<FarmBloc, FarmState>(
      'does nothing in create mode',
      build: () => build(),
      act: (b) => b.add(const FarmDeleteRequested()),
      expect: () => <FarmState>[],
    );
  });
}
