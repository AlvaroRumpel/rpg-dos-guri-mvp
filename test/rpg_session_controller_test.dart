import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rpg_dos_guri/features/rpg/application/application.dart';
import 'package:rpg_dos_guri/features/rpg/domain/domain.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('PIN correto libera mestre e PIN errado nao libera', () async {
    final controller = RpgSessionController.seeded();

    expect(await controller.enterAsMasterWithPin('1234'), isTrue);
    controller.backToLanding();

    expect(await controller.enterAsMasterWithPin('0000'), isFalse);
    expect(controller.role, UserRole.landing);
    expect(await controller.enterAsMasterWithPin('1234'), isTrue);
    expect(controller.role, UserRole.master);
  });

  test('pedido de poder entra na fila e aprovacao marca como usado', () {
    final controller = RpgSessionController.seeded();
    final character = controller.characters.first.copyWith(
      powers: const [
        PowerEntry(
          id: 'power-1',
          name: 'Golpe Teste',
          type: 'Habilidade',
          description: 'Teste',
          suggestedTest: 'Combate',
          effect: 'Dano',
          usageLimit: UsageLimit.session,
        ),
      ],
    );
    controller.updateCharacter(character);

    controller.requestPowerUse(character.id, 'power-1');
    expect(controller.powerUseRequests, hasLength(1));

    controller.approvePowerUse(controller.powerUseRequests.first.id);
    expect(controller.powerUseRequests, isEmpty);
    expect(controller.characters.first.powers.first.used, isTrue);
  });

  test('descartar pedido nao marca poder como usado', () {
    final controller = RpgSessionController.seeded();
    final character = controller.characters.first.copyWith(
      powers: const [
        PowerEntry(
          id: 'power-1',
          name: 'Golpe Teste',
          type: 'Habilidade',
          description: 'Teste',
          suggestedTest: 'Combate',
          effect: 'Dano',
          usageLimit: UsageLimit.session,
        ),
      ],
    );
    controller.updateCharacter(character);

    controller.requestPowerUse(character.id, 'power-1');
    controller.discardPowerUseRequest(controller.powerUseRequests.first.id);

    expect(controller.powerUseRequests, isEmpty);
    expect(controller.characters.first.powers.first.used, isFalse);
  });

  test('arquivar remove ficha das listas ativas e restaurar volta', () {
    final controller = RpgSessionController.seeded();
    final characterId = controller.characters.first.id;

    controller.archiveCharacter(characterId);
    expect(
      controller.activeCharacters.any(
        (character) => character.id == characterId,
      ),
      isFalse,
    );
    expect(
      controller.archivedCharacters.any(
        (character) => character.id == characterId,
      ),
      isTrue,
    );

    controller.restoreCharacter(characterId);
    expect(
      controller.activeCharacters.any(
        (character) => character.id == characterId,
      ),
      isTrue,
    );
  });

  test('resets afetam apenas os limites corretos', () {
    final controller = RpgSessionController.seeded();
    final character = controller.characters.first.copyWith(
      powers: const [
        PowerEntry(
          id: 'combat',
          name: 'Combate',
          type: 'Habilidade',
          description: 'Teste',
          suggestedTest: 'Combate',
          effect: 'Dano',
          usageLimit: UsageLimit.combat,
          used: true,
        ),
        PowerEntry(
          id: 'session',
          name: 'Sessao',
          type: 'Habilidade',
          description: 'Teste',
          suggestedTest: 'Combate',
          effect: 'Dano',
          usageLimit: UsageLimit.session,
          used: true,
        ),
        PowerEntry(
          id: 'rest',
          name: 'Descanso',
          type: 'Habilidade',
          description: 'Teste',
          suggestedTest: 'Combate',
          effect: 'Dano',
          usageLimit: UsageLimit.longRest,
          used: true,
        ),
      ],
    );
    controller.updateCharacter(character);

    controller.resetCombatUses();
    expect(controller.characters.first.powers[0].used, isFalse);
    expect(controller.characters.first.powers[1].used, isTrue);
    expect(controller.characters.first.powers[2].used, isTrue);

    controller.resetSessionUses();
    expect(controller.characters.first.powers[1].used, isFalse);
    expect(controller.characters.first.powers[2].used, isTrue);

    controller.resetLongRestUses();
    expect(controller.characters.first.powers[2].used, isFalse);
  });

  test('query de mesa vence cache local', () async {
    SharedPreferences.setMockInitialValues({'rpg.lastTableCode': 'GURI-1111'});
    final controller = RpgSessionController.seeded();

    await controller.bootstrap(initialTableCode: 'GURI-2222');

    expect(controller.table.code, 'GURI-2222');
  });

  test('troca de classe remove pedidos de poderes descartados', () {
    final controller = RpgSessionController.seeded();
    addTearDown(controller.dispose);
    final character = controller.characters.first.copyWith(
      powers: const [
        PowerEntry(
          id: 'classe-antiga',
          name: 'Golpe antigo',
          type: 'Habilidade de classe',
          description: '',
          suggestedTest: '',
          effect: '',
          usageLimit: UsageLimit.combat,
        ),
      ],
    );
    controller.updateCharacter(character);
    controller.requestPowerUse(character.id, 'classe-antiga');

    controller.updateCharacter(character.copyWith(characterClass: 'Ladino'));

    expect(controller.powerUseRequests, isEmpty);
  });
}
