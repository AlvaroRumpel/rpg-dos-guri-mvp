part of '../shell/session_shell.dart';

void _showDetailDialog(
  BuildContext context, {
  required String title,
  required String subtitle,
  required List<MapEntry<String, String?>> fields,
}) {
  showDialog<void>(
    context: context,
    builder: (context) => RpgModal(
      title: Text(title),
      eyebrow: subtitle,
      width: 680,
      content: RpgFieldGroup(
        children: [
          for (final field in fields)
            if (field.value?.trim().isNotEmpty == true)
              RpgInfoRow(label: field.key, value: field.value!.trim()),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    ),
  );
}

void _showPowerEntryDetails(BuildContext context, PowerEntry power) {
  _showDetailDialog(
    context,
    title: power.name,
    subtitle: power.type,
    fields: [
      MapEntry('Descrição', power.description),
      MapEntry('Teste sugerido', power.suggestedTest),
      MapEntry('Efeito', power.effect),
      MapEntry('Limite', _usageLabel(power.usageLimit)),
      MapEntry('Origem', power.origin),
      MapEntry('Uso', power.actionCost),
      MapEntry('Alcance', power.range),
      MapEntry('Duração', power.duration),
      MapEntry('Rolagem', power.roll),
      MapEntry('Dano', power.damage),
      MapEntry('Cura', power.healing),
      MapEntry('Efeito extra', power.extraEffect),
      MapEntry('Notas', power.notes),
      MapEntry('Fonte', power.source),
    ],
  );
}

void _showMasterPinDialog(BuildContext context) {
  final controller = context.read<RpgSessionController>();
  if (controller.masterAuthorized) {
    controller.enterAsMaster();
    return;
  }
  final pin = TextEditingController();
  final creating = !controller.hasMasterPin;

  showDialog<void>(
    context: context,
    builder: (context) => RpgModal(
      title: Text(creating ? 'Criar PIN do mestre' : 'PIN do mestre'),
      content: RpgFieldGroup(
        children: [
          TextField(
            controller: pin,
            autofocus: true,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: creating ? 'Novo PIN' : 'PIN',
              helperText:
                  'Use pelo menos 4 dígitos. Esta é uma proteção doméstica.',
            ),
          ),
          const RpgInfoRow(
            label: 'Aviso',
            value:
                'O PIN evita acesso casual, mas não substitui autenticação real.',
            icon: Icons.lock,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () async {
            final ok = await context
                .read<RpgSessionController>()
                .enterAsMasterWithPin(pin.text);
            if (!context.mounted) return;
            if (ok) {
              Navigator.of(context).pop();
              return;
            }
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('PIN inválido.')));
          },
          child: Text(creating ? 'Criar e entrar' : 'Entrar'),
        ),
      ],
    ),
  );
}

void _showArchiveCharacterDialog(
  BuildContext context,
  CharacterSheet character,
) {
  showDialog<void>(
    context: context,
    builder: (context) => RpgModal(
      title: Text('Arquivar ${character.name}?'),
      content: const Text(
        'A ficha sairá da landing, da companhia ativa e de novos combates. O mestre pode restaurar depois.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            context.read<RpgSessionController>().archiveCharacter(character.id);
            Navigator.of(context).pop();
          },
          child: const Text('Arquivar'),
        ),
      ],
    ),
  );
}

void _showDefeatedStateDialog(
  BuildContext context,
  CombatParticipant participant,
) {
  showDialog<void>(
    context: context,
    builder: (context) => RpgModal(
      title: Text('Estado de ${participant.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final state in DefeatedState.values)
            RpgPanel(
              margin: const EdgeInsets.only(bottom: 8),
              borderColor: participant.defeatedState == state
                  ? _defeatedColor(state)
                  : RpgTheme.line,
              child: InkWell(
                onTap: () {
                  context.read<RpgSessionController>().setDefeatedState(
                    participant.id,
                    state,
                  );
                  Navigator.of(context).pop();
                },
                child: Row(
                  children: [
                    RpgStateLamp(state: state),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _defeatedLabel(state),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (participant.defeatedState == state)
                      const Icon(Icons.check, color: RpgTheme.gold),
                  ],
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    ),
  );
}

void _showTableDialog(BuildContext context) {
  final controller = context.read<RpgSessionController>();
  final name = TextEditingController(text: controller.table.name);
  final code = TextEditingController(text: controller.table.code);

  showDialog<void>(
    context: context,
    builder: (context) => RpgModal(
      title: const Text('Configurar mesa'),
      content: RpgFieldGroup(
        children: [
          TextField(
            controller: name,
            decoration: const InputDecoration(labelText: 'Nome da mesa'),
          ),
          TextField(
            controller: code,
            decoration: const InputDecoration(labelText: 'Código local'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        OutlinedButton(
          onPressed: () {
            context.read<RpgSessionController>().regenerateTableCode();
            Navigator.of(context).pop();
          },
          child: const Text('Gerar código'),
        ),
        FilledButton(
          onPressed: () {
            context.read<RpgSessionController>().updateTable(
              name: name.text,
              code: code.text,
            );
            Navigator.of(context).pop();
          },
          child: const Text('Salvar'),
        ),
      ],
    ),
  );
}

void _showTableCodeDialog(BuildContext context) {
  final code = TextEditingController(
    text: context.read<RpgSessionController>().table.code,
  );

  showDialog<void>(
    context: context,
    builder: (context) => RpgModal(
      title: const Text('Entrar ou criar mesa'),
      content: RpgFieldGroup(
        children: [
          TextField(
            controller: code,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Código da mesa',
              helperText: 'Exemplo: GURI-1234',
            ),
          ),
          const RpgInfoRow(
            label: 'Acesso',
            value:
                'Sem login. O código da mesa e o link são a chave de entrada.',
            icon: Icons.link,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () async {
            await context.read<RpgSessionController>().openTableByCode(
              code.text,
            );
            if (context.mounted) Navigator.of(context).pop();
          },
          child: const Text('Entrar/criar'),
        ),
      ],
    ),
  );
}

void _showLevelUpDialog(BuildContext context, CharacterSheet character) {
  final controller = context.read<RpgSessionController>();
  if (character.level >= 10) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Nível máximo 10.')));
    return;
  }

  final newLevel = character.level + 1;
  final isMage = _sameOptionName(character.characterClass, 'Mago');
  final spellOptions = isMage
      ? controller.spellLibrary.where((spell) {
          final wantsStrong = newLevel.isOdd;
          return wantsStrong
              ? spell.usageLimit == UsageLimit.combat
              : spell.usageLimit == UsageLimit.free;
        }).toList()
      : <SpellTemplate>[];
  SpellTemplate? selectedSpell = spellOptions.isEmpty
      ? null
      : spellOptions.first;
  final progression = _firstOrNull(
    controller.classProgression,
    (entry) =>
        _sameOptionName(entry.characterClass, character.characterClass) &&
        entry.level == newLevel,
  );

  showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => RpgModal(
        title: Text('${character.name} sobe para nível $newLevel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Classe atual: ${character.characterClass}'),
            const SizedBox(height: 12),
            if (isMage) ...[
              Text(
                newLevel.isOdd
                    ? 'Escolha 1 magia forte.'
                    : 'Escolha 1 nova magia simples.',
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<SpellTemplate>(
                initialValue: selectedSpell,
                isExpanded: true,
                items: spellOptions
                    .map(
                      (spell) => DropdownMenuItem(
                        value: spell,
                        child: _dropdownLabel(spell.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => selectedSpell = value),
                decoration: const InputDecoration(labelText: 'Magia'),
              ),
            ] else ...[
              Text(progression?.name ?? 'Habilidade preparada'),
              const SizedBox(height: 6),
              Text(
                progression?.description ??
                    'Detalhar conforme a tabela oficial da classe.',
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              controller.levelUp(
                character.id,
                selectedSpellId: selectedSpell?.id,
              );
              Navigator.of(context).pop();
            },
            child: const Text('Confirmar evolucao'),
          ),
        ],
      ),
    ),
  );
}

void _showPowerLibraryDialog(BuildContext context, CharacterSheet character) {
  final controller = context.read<RpgSessionController>();
  var selectedPower = controller.powerLibrary.isEmpty
      ? null
      : controller.powerLibrary.first;
  var selectedSpell = controller.spellLibrary.isEmpty
      ? null
      : controller.spellLibrary.first;
  var selectedRitual = controller.ritualLibrary.isEmpty
      ? null
      : controller.ritualLibrary.first;

  showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => RpgModal(
        title: Text('Biblioteca de ${character.name}'),
        content: RpgFieldGroup(
          children: [
            RpgFormSection(
              title: 'Poderes',
              icon: Icons.auto_awesome,
              children: [
                if (controller.powerLibrary.isEmpty)
                  const Text('Biblioteca de poderes ainda carregando.')
                else
                  DropdownButtonFormField<PowerTemplate>(
                    initialValue: selectedPower,
                    isExpanded: true,
                    items: controller.powerLibrary
                        .map(
                          (power) => DropdownMenuItem(
                            value: power,
                            child: _dropdownLabel(power.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => selectedPower = value ?? selectedPower),
                    decoration: const InputDecoration(labelText: 'Poder'),
                  ),
                if (selectedPower != null) ...[
                  RpgInfoRow(label: 'Efeito', value: selectedPower!.effect),
                  RpgInfoRow(
                    label: 'Uso',
                    value: _joinDialogDetails([
                      selectedPower!.origin,
                      _usageLabel(selectedPower!.usageLimit),
                      selectedPower!.actionCost,
                    ]),
                  ),
                ],
              ],
            ),
            RpgFormSection(
              title: 'Grimório',
              icon: Icons.menu_book,
              children: [
                if (controller.spellLibrary.isEmpty)
                  const Text('Biblioteca de magias ainda carregando.')
                else
                  DropdownButtonFormField<SpellTemplate>(
                    initialValue: selectedSpell,
                    isExpanded: true,
                    items: controller.spellLibrary
                        .map(
                          (spell) => DropdownMenuItem(
                            value: spell,
                            child: _dropdownLabel(
                              '${spell.name} - ${spell.tier}',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => selectedSpell = value ?? selectedSpell),
                    decoration: const InputDecoration(labelText: 'Magia'),
                  ),
                if (selectedSpell != null) ...[
                  RpgInfoRow(label: 'Efeito', value: selectedSpell!.effect),
                  RpgInfoRow(
                    label: 'Uso',
                    value: _joinDialogDetails([
                      selectedSpell!.tier,
                      _usageLabel(selectedSpell!.usageLimit),
                      selectedSpell!.actionCost,
                      selectedSpell!.range,
                      selectedSpell!.duration,
                    ]),
                  ),
                ],
              ],
            ),
            RpgFormSection(
              title: 'Rituais',
              icon: Icons.history_edu,
              children: [
                if (controller.ritualLibrary.isEmpty)
                  const Text('Biblioteca de rituais ainda carregando.')
                else
                  DropdownButtonFormField<RitualTemplate>(
                    initialValue: selectedRitual,
                    isExpanded: true,
                    items: controller.ritualLibrary
                        .map(
                          (ritual) => DropdownMenuItem(
                            value: ritual,
                            child: _dropdownLabel(ritual.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(
                      () => selectedRitual = value ?? selectedRitual,
                    ),
                    decoration: const InputDecoration(labelText: 'Ritual'),
                  ),
                if (selectedRitual != null) ...[
                  RpgInfoRow(
                    label: 'Rolagem',
                    value: selectedRitual!.suggestedRoll,
                  ),
                  RpgInfoRow(
                    label: 'Dificuldade',
                    value: selectedRitual!.difficulty,
                  ),
                ],
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
          OutlinedButton(
            onPressed: selectedPower == null
                ? null
                : () {
                    controller.addPowerToCharacter(
                      character.id,
                      selectedPower!,
                    );
                    Navigator.of(context).pop();
                  },
            child: const Text('Adicionar poder'),
          ),
          OutlinedButton(
            onPressed: selectedRitual == null
                ? null
                : () {
                    controller.addRitualToCharacter(
                      character.id,
                      selectedRitual!,
                    );
                    Navigator.of(context).pop();
                  },
            child: const Text('Adicionar ritual'),
          ),
          FilledButton(
            onPressed: selectedSpell == null
                ? null
                : () {
                    controller.addSpellToCharacter(
                      character.id,
                      selectedSpell!,
                    );
                    Navigator.of(context).pop();
                  },
            child: const Text('Adicionar magia'),
          ),
        ],
      ),
    ),
  );
}

void _showInventoryEditor(BuildContext context, CharacterSheet character) {
  final addQuantity = TextEditingController(text: '1');
  final initialLibrary = context.read<RpgSessionController>().itemLibrary;
  var selectedTemplate = initialLibrary.isEmpty ? null : initialLibrary.first;

  showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        final controller = context.watch<RpgSessionController>();
        final liveCharacter =
            _firstOrNull(
              controller.characters,
              (item) => item.id == character.id,
            ) ??
            character;

        return RpgModal(
          title: Text('Inventário de ${liveCharacter.name}'),
          content: RpgFieldGroup(
            children: [
              RpgFormSection(
                title: 'Itens atuais',
                icon: Icons.inventory_2,
                children: [
                  if (liveCharacter.inventory.isEmpty)
                    const Text('Inventário vazio.')
                  else
                    for (final item in liveCharacter.inventory)
                      RpgPanel(
                        inset: true,
                        child: Wrap(
                          spacing: RpgSpacing.sm,
                          runSpacing: RpgSpacing.sm,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            SizedBox(
                              width: 250,
                              child: RpgFieldGroup(
                                gap: RpgSpacing.xs,
                                children: [
                                  Text(
                                    '${item.name} x${item.quantity}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  Text(
                                    item.description,
                                    style: const TextStyle(
                                      color: RpgTheme.mutedInk,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (item.roll != null)
                                    RpgInfoRow(
                                      label: 'Rolagem',
                                      value:
                                          '${item.roll} + ${item.fixedBonus}',
                                    ),
                                ],
                              ),
                            ),
                            RpgStepper(
                              value: item.quantity,
                              onChanged: (value) =>
                                  controller.upsertInventoryItem(
                                    liveCharacter.id,
                                    item.copyWith(quantity: value),
                                  ),
                            ),
                            RpgIconButton(
                              tooltip: 'Remover',
                              danger: true,
                              onPressed: () => controller.removeInventoryItem(
                                liveCharacter.id,
                                item.id,
                              ),
                              icon: Icons.delete,
                            ),
                          ],
                        ),
                      ),
                ],
              ),
              RpgFormSection(
                title: 'Adicionar da biblioteca',
                icon: Icons.add_box,
                children: [
                  if (controller.itemLibrary.isEmpty)
                    const Text('Biblioteca oficial ainda carregando.')
                  else
                    DropdownButtonFormField<ItemTemplate>(
                      initialValue: selectedTemplate,
                      isExpanded: true,
                      items: controller.itemLibrary
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: _dropdownLabel(item.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(
                        () => selectedTemplate = value ?? selectedTemplate,
                      ),
                      decoration: const InputDecoration(labelText: 'Item'),
                    ),
                  RpgFieldGrid(
                    children: [
                      TextField(
                        controller: addQuantity,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Quantidade',
                        ),
                      ),
                    ],
                  ),
                  RpgButton(
                    onPressed: selectedTemplate == null
                        ? null
                        : () => controller.addItemToCharacter(
                            liveCharacter.id,
                            selectedTemplate!,
                            quantity: int.tryParse(addQuantity.text) ?? 1,
                          ),
                    icon: Icons.add,
                    label: 'Adicionar item da biblioteca',
                    variant: RpgButtonVariant.primary,
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    ),
  );
}

enum _ValueDialogMode { damage, heal }

void _showValueDialog(
  BuildContext context, {
  required String title,
  required CombatParticipant target,
  required _ValueDialogMode mode,
  required ValueChanged<int> onConfirm,
}) {
  var amount = 0;
  showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        final preview = switch (mode) {
          _ValueDialogMode.damage => (target.currentHp - amount).clamp(
            0,
            target.maxHp,
          ),
          _ValueDialogMode.heal => (target.currentHp + amount).clamp(
            0,
            target.maxHp,
          ),
        };
        final danger = mode == _ValueDialogMode.damage;
        return RpgModal(
          eyebrow: danger ? 'Aplicar dano' : 'Aplicar cura',
          title: Text(target.name),
          width: 460,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RpgPanel(
                inset: true,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('VIDA ATUAL', style: RpgTextStyles.eyebrow()),
                        Text(
                          '${target.currentHp} -> $preview / ${target.maxHp}',
                          style: RpgTextStyles.mono(
                            color: danger
                                ? RpgTheme.danger
                                : RpgTheme.mossBright,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    RpgHpBar(
                      current: preview,
                      max: target.maxHp,
                      showLabel: false,
                      height: 7,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('VALOR FINAL', style: RpgTextStyles.eyebrow()),
              const SizedBox(height: 8),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  RpgStepper(
                    value: amount,
                    onChanged: (value) => setState(() => amount = value),
                    min: 0,
                    max: 99,
                  ),
                  for (final value in [1, 3, 5, 8, 12])
                    RpgButton(
                      label: '+$value',
                      small: true,
                      onPressed: () => setState(
                        () => amount = (amount + value).clamp(0, 99),
                      ),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            RpgButton(
              label: 'Cancelar',
              onPressed: () => Navigator.of(context).pop(),
            ),
            RpgButton(
              label: danger ? 'Aplicar dano' : 'Aplicar cura',
              icon: danger ? Icons.remove_circle : Icons.add_circle,
              variant: danger
                  ? RpgButtonVariant.danger
                  : RpgButtonVariant.primary,
              onPressed: amount == 0
                  ? null
                  : () {
                      onConfirm(amount);
                      Navigator.of(context).pop();
                    },
            ),
          ],
        );
      },
    ),
  );
}

void _showStatusDialog(BuildContext context, CombatParticipant participant) {
  final name = TextEditingController();
  final description = TextEditingController();
  final duration = TextEditingController();
  var type = 'Narrativo';
  var visibleToPlayer = true;
  final presets = [
    'Caido',
    'Cego',
    'Preso',
    'Envenenado',
    'Abencoado',
    'Marcado',
    'Sangrando',
    'Atordoado',
  ];
  showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => RpgModal(
        eyebrow: 'Aplicar status',
        title: Text(participant.name),
        content: RpgFieldGroup(
          children: [
            if (participant.statuses.isNotEmpty) ...[
              Text('ATUAIS', style: RpgTextStyles.eyebrow()),
              const SizedBox(height: 6),
              for (final status in participant.statuses)
                RpgPanel(
                  inset: true,
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${status.name} · ${status.type}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      RpgIconButton(
                        icon: Icons.close,
                        tooltip: 'Remover status',
                        onPressed: () {
                          context.read<RpgSessionController>().removeStatus(
                            participant.id,
                            status.id,
                          );
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 10),
            ],
            Text('PREDEFINIDOS', style: RpgTextStyles.eyebrow()),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final preset in presets)
                  RpgButton(
                    label: preset,
                    small: true,
                    onPressed: () => setState(() => name.text = preset),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: type,
              isExpanded: true,
              items:
                  [
                        'Condicao',
                        'Bonus',
                        'Penalidade',
                        'Vantagem',
                        'Desvantagem',
                        'Narrativo',
                      ]
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: _dropdownLabel(item),
                        ),
                      )
                      .toList(),
              onChanged: (value) => setState(() => type = value ?? type),
              decoration: const InputDecoration(labelText: 'Tipo'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: duration,
              decoration: const InputDecoration(labelText: 'Duração opcional'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: description,
              decoration: const InputDecoration(labelText: 'Descricao'),
              minLines: 2,
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            RpgButton(
              label: visibleToPlayer ? 'Visivel' : 'Oculto',
              icon: visibleToPlayer ? Icons.visibility : Icons.visibility_off,
              onPressed: () =>
                  setState(() => visibleToPlayer = !visibleToPlayer),
            ),
          ],
        ),
        actions: [
          RpgButton(
            label: 'Cancelar',
            onPressed: () => Navigator.of(context).pop(),
          ),
          RpgButton(
            label: 'Aplicar status',
            icon: Icons.add,
            variant: RpgButtonVariant.primary,
            onPressed: () {
              context.read<RpgSessionController>().addStatus(
                participant.id,
                StatusEntry(
                  id: 'status-${DateTime.now().microsecondsSinceEpoch}',
                  name: name.text.trim().isEmpty ? 'Status' : name.text.trim(),
                  type: type,
                  duration: duration.text.trim(),
                  visibleToPlayer: visibleToPlayer,
                  description: description.text,
                ),
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    ),
  );
}

void _showMonsterPicker(BuildContext context) {
  final controller = context.read<RpgSessionController>();
  if (controller.monsters.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Biblioteca de monstros ainda carregando.')),
    );
    return;
  }
  var selected = controller.monsters.first;
  final quantity = TextEditingController(text: '1');
  final maxHp = TextEditingController(text: '${selected.maxHp}');
  final defense = TextEditingController(text: '${selected.defense}');
  final damage = TextEditingController(text: selected.damage);

  showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => RpgModal(
        title: const Text('Adicionar monstro'),
        content: RpgFieldGroup(
          children: [
            DropdownButtonFormField<MonsterTemplate>(
              initialValue: selected,
              isExpanded: true,
              items: controller.monsters
                  .map(
                    (monster) => DropdownMenuItem(
                      value: monster,
                      child: _dropdownLabel(monster.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() {
                selected = value ?? selected;
                maxHp.text = '${selected.maxHp}';
                defense.text = '${selected.defense}';
                damage.text = selected.damage;
              }),
              decoration: const InputDecoration(labelText: 'Monstro'),
            ),
            RpgFieldGrid(
              children: [
                TextField(
                  controller: quantity,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantidade'),
                ),
                TextField(
                  controller: maxHp,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Vida'),
                ),
                TextField(
                  controller: defense,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Defesa'),
                ),
                TextField(
                  controller: damage,
                  decoration: const InputDecoration(labelText: 'Dano sugerido'),
                ),
              ],
            ),
            RpgInfoRow(
              label: 'Ataque',
              value: '${selected.attack} - ${selected.instinct}',
              icon: Icons.gavel,
            ),
            RpgInfoRow(
              label: 'Especial',
              value: selected.special,
              icon: Icons.auto_awesome,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              controller.addMonsterToCombat(
                selected,
                int.tryParse(quantity.text) ?? 1,
                maxHp: int.tryParse(maxHp.text),
                defense: int.tryParse(defense.text),
                damageSuggestion: damage.text,
              );
              Navigator.of(context).pop();
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    ),
  );
}

void _showCustomParticipantDialog(BuildContext context) {
  final name = TextEditingController(text: 'NPC improvisado');
  final maxHp = TextEditingController(text: '10');
  final defense = TextEditingController(text: '10');
  final damage = TextEditingController();
  var type = ParticipantType.npcNeutral;

  showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => RpgModal(
        title: const Text('Adicionar NPC ou objeto'),
        content: RpgFieldGroup(
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            DropdownButtonFormField<ParticipantType>(
              initialValue: type,
              isExpanded: true,
              items:
                  [
                        ParticipantType.npcAlly,
                        ParticipantType.npcNeutral,
                        ParticipantType.npcEnemy,
                        ParticipantType.object,
                      ]
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: _dropdownLabel(_participantTypeLabel(item)),
                        ),
                      )
                      .toList(),
              onChanged: (value) => setState(() => type = value ?? type),
              decoration: const InputDecoration(labelText: 'Tipo'),
            ),
            RpgFieldGrid(
              children: [
                TextField(
                  controller: maxHp,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Vida maxima'),
                ),
                TextField(
                  controller: defense,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Defesa'),
                ),
                TextField(
                  controller: damage,
                  decoration: const InputDecoration(
                    labelText: 'Dano sugerido opcional',
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              context.read<RpgSessionController>().addCustomParticipant(
                name: name.text,
                type: type,
                maxHp: int.tryParse(maxHp.text) ?? 10,
                defense: int.tryParse(defense.text) ?? 10,
                damageSuggestion: damage.text,
              );
              Navigator.of(context).pop();
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    ),
  );
}

void _showParticipantEditDialog(
  BuildContext context,
  CombatParticipant participant,
) {
  final name = TextEditingController(text: participant.name);
  final currentHp = TextEditingController(text: '${participant.currentHp}');
  final maxHp = TextEditingController(text: '${participant.maxHp}');
  final defense = TextEditingController(text: '${participant.defense}');
  final damage = TextEditingController(
    text: participant.damageSuggestion ?? '',
  );
  var type = participant.type;

  showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => RpgModal(
        title: const Text('Editar participante'),
        content: RpgFieldGroup(
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            DropdownButtonFormField<ParticipantType>(
              initialValue: type,
              isExpanded: true,
              items: ParticipantType.values
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: _dropdownLabel(_participantTypeLabel(item)),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => type = value ?? type),
              decoration: const InputDecoration(labelText: 'Tipo'),
            ),
            RpgFieldGrid(
              children: [
                TextField(
                  controller: currentHp,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Vida atual'),
                ),
                TextField(
                  controller: maxHp,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Vida maxima'),
                ),
                TextField(
                  controller: defense,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Defesa'),
                ),
                TextField(
                  controller: damage,
                  decoration: const InputDecoration(labelText: 'Dano sugerido'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final editedMaxHp =
                  (int.tryParse(maxHp.text) ?? participant.maxHp)
                      .clamp(1, 999)
                      .toInt();
              final editedCurrentHp =
                  (int.tryParse(currentHp.text) ?? participant.currentHp)
                      .clamp(0, editedMaxHp)
                      .toInt();
              context.read<RpgSessionController>().updateParticipant(
                participant.copyWith(
                  name: name.text.trim().isEmpty
                      ? participant.name
                      : name.text.trim(),
                  type: type,
                  currentHp: editedCurrentHp,
                  maxHp: editedMaxHp,
                  defense: (int.tryParse(defense.text) ?? participant.defense)
                      .clamp(0, 99)
                      .toInt(),
                  damageSuggestion: damage.text.trim(),
                ),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    ),
  );
}

void _showConsumableDialog(
  BuildContext context,
  CharacterSheet character,
  InventoryItem item,
) {
  final combat = context.read<RpgSessionController>().activeCombat;
  if (combat == null) return;
  final rolled = TextEditingController(text: '0');
  var targetId = combat.participants.first.id;

  showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => RpgModal(
        title: Text(item.name),
        content: RpgFieldGroup(
          children: [
            RpgInfoRow(
              label: 'Rolagem física',
              value:
                  'Role ${item.roll ?? 'valor definido'} físico. Bônus fixo: +${item.fixedBonus}.',
              icon: Icons.casino,
            ),
            RpgFieldGrid(
              children: [
                TextField(
                  controller: rolled,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Valor rolado/informado',
                  ),
                ),
                DropdownButtonFormField<String>(
                  initialValue: targetId,
                  isExpanded: true,
                  items: combat.participants
                      .map(
                        (participant) => DropdownMenuItem(
                          value: participant.id,
                          child: _dropdownLabel(participant.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => targetId = value ?? targetId),
                  decoration: const InputDecoration(labelText: 'Alvo'),
                ),
              ],
            ),
            RpgInfoRow(
              label: 'Total',
              value:
                  '${(int.tryParse(rolled.text) ?? 0) + item.fixedBonus} aplicado',
              icon: Icons.functions,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              context.read<RpgSessionController>().applyConsumable(
                characterId: character.id,
                itemId: item.id,
                targetParticipantId: targetId,
                rolledValue: int.tryParse(rolled.text) ?? 0,
              );
              Navigator.of(context).pop();
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    ),
  );
}

void _showJoinRequestDialog(BuildContext context) {
  final name = TextEditingController();

  showDialog<void>(
    context: context,
    builder: (context) => RpgModal(
      eyebrow: 'Pedido de entrada',
      title: const Text('Solicitar entrada'),
      width: 460,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const RpgPortrait(
            label: 'novo jogador',
            sigil: 'moon',
            size: 78,
            color: RpgTheme.lineGold,
          ),
          const SizedBox(height: 16),
          const Text(
            'Diga seu nome ao mestre. Quando ele aprovar, uma ficha em branco sera criada para voce editar.',
            textAlign: TextAlign.center,
            style: TextStyle(color: RpgTheme.mutedInk, fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: name,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Seu nome'),
          ),
        ],
      ),
      actions: [
        RpgButton(
          onPressed: () => Navigator.of(context).pop(),
          label: 'Cancelar',
        ),
        RpgButton(
          onPressed: () {
            context.read<RpgSessionController>().requestPlayerApproval(
              name.text,
            );
            Navigator.of(context).pop();
          },
          label: 'Enviar pedido',
          icon: Icons.check,
          variant: RpgButtonVariant.primary,
        ),
      ],
    ),
  );
}

void _showCharacterForm(BuildContext context, {CharacterSheet? existing}) {
  final controller = context.read<RpgSessionController>();
  final raceOptions = controller.races.map((item) => item.name).toList();
  final classOptions = controller.classes.map((item) => item.name).toList();
  final weaponOptions = controller.weapons.map((item) => item.name).toList();
  final shieldOptions = controller.shields.map((item) => item.name).toList();
  final armorOptions = controller.armors.map((item) => item.name).toList();
  final accessoryOptions = controller.accessories
      .map((item) => item.name)
      .toList();
  final secondaryOptions = [...weaponOptions, ...shieldOptions];
  final name = TextEditingController(text: existing?.name ?? '');
  final concept = TextEditingController(text: existing?.concept ?? '');
  final currentHp = TextEditingController(text: '${existing?.currentHp ?? 10}');
  final coins = TextEditingController(text: '${existing?.coins ?? 5}');
  final attributeControllers = {
    for (final key in _attributeNames)
      key: TextEditingController(text: '${existing?.attributes[key] ?? 0}'),
  };
  final skillControllers = {
    for (final key in _skillNames)
      key: TextEditingController(text: '${existing?.skills[key] ?? 0}'),
  };
  var race = _officialValue(existing?.race, raceOptions, 'Humano');
  var characterClass = _officialValue(
    existing?.characterClass,
    classOptions,
    'Guerreiro',
  );
  final mageSpellSelections = <int, String?>{};
  var armor = _officialValue(existing?.armor, armorOptions, 'Sem armadura');
  var mainWeapon = _officialValue(
    existing?.mainWeapon,
    weaponOptions,
    weaponOptions.isNotEmpty
        ? weaponOptions.first
        : 'Soco, chute ou arma improvisada leve',
  );
  var secondaryItem = _officialValue(
    existing?.secondaryItem,
    secondaryOptions,
    secondaryOptions.isNotEmpty ? secondaryOptions.first : mainWeapon,
  );
  var accessoryOne = _officialValue(
    existing?.accessories.isNotEmpty == true ? existing!.accessories[0] : null,
    accessoryOptions,
    '',
  );
  var accessoryTwo = _officialValue(
    existing?.accessories.length == 2 ? existing!.accessories[1] : null,
    accessoryOptions,
    '',
  );

  showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => RpgModal(
        title: Text(existing == null ? 'Criar ficha' : 'Editar ficha'),
        width: 760,
        content: RpgFieldGroup(
          children: [
            RpgFormSection(
              title: 'Identidade',
              icon: Icons.badge,
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Nome'),
                ),
                TextField(
                  controller: concept,
                  decoration: const InputDecoration(labelText: 'Conceito'),
                ),
                RpgFieldGrid(
                  minColumnWidth: 230,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: race,
                      isExpanded: true,
                      items: _stringDropdownItems(
                        _ensureDropdownOptions(raceOptions, race),
                      ),
                      onChanged: (value) =>
                          setState(() => race = value ?? race),
                      decoration: const InputDecoration(labelText: 'Raça'),
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: characterClass,
                      isExpanded: true,
                      items: _stringDropdownItems(
                        _ensureDropdownOptions(classOptions, characterClass),
                      ),
                      onChanged: (value) => setState(() {
                        characterClass = value ?? characterClass;
                        mageSpellSelections.clear();
                      }),
                      decoration: const InputDecoration(labelText: 'Classe'),
                    ),
                  ],
                ),
              ],
            ),
            if (existing != null &&
                !_sameOptionName(existing.characterClass, characterClass) &&
                _sameOptionName(characterClass, 'Mago') &&
                existing.level > 1)
              RpgFormSection(
                title: 'Grimório do mago',
                subtitle: 'escolha as magias adquiridas nos níveis anteriores',
                icon: Icons.auto_awesome,
                children: [
                  for (var level = 2; level <= existing.level; level += 1)
                    DropdownButtonFormField<String>(
                      initialValue: mageSpellSelections[level],
                      isExpanded: true,
                      items: [
                        for (final spell in controller.spellLibrary)
                          if ((level.isOdd
                                  ? spell.usageLimit == UsageLimit.combat
                                  : spell.usageLimit == UsageLimit.free) &&
                              !mageSpellSelections.entries.any(
                                (entry) =>
                                    entry.key != level &&
                                    entry.value == spell.id,
                              ))
                            DropdownMenuItem(
                              value: spell.id,
                              child: _dropdownLabel(spell.name),
                            ),
                      ],
                      onChanged: (value) =>
                          setState(() => mageSpellSelections[level] = value),
                      decoration: InputDecoration(
                        labelText: level.isOdd
                            ? 'Nível $level - magia forte'
                            : 'Nível $level - magia simples',
                      ),
                    ),
                ],
              ),
            RpgFormSection(
              title: 'Combate',
              icon: Icons.shield,
              children: [
                RpgFieldGrid(
                  minColumnWidth: 230,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: armor,
                      isExpanded: true,
                      items: _stringDropdownItems(
                        _ensureDropdownOptions(armorOptions, armor),
                      ),
                      onChanged: (value) =>
                          setState(() => armor = value ?? armor),
                      decoration: const InputDecoration(labelText: 'Armadura'),
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: mainWeapon,
                      isExpanded: true,
                      items: _stringDropdownItems(
                        _ensureDropdownOptions(weaponOptions, mainWeapon),
                      ),
                      onChanged: (value) =>
                          setState(() => mainWeapon = value ?? mainWeapon),
                      decoration: const InputDecoration(
                        labelText: 'Arma principal',
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: secondaryItem,
                      isExpanded: true,
                      items: _stringDropdownItems(
                        _ensureDropdownOptions(secondaryOptions, secondaryItem),
                      ),
                      onChanged: (value) => setState(
                        () => secondaryItem = value ?? secondaryItem,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Secundário ou escudo',
                      ),
                    ),
                    TextField(
                      controller: currentHp,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Vida atual',
                      ),
                    ),
                    TextField(
                      controller: coins,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Moedas'),
                    ),
                  ],
                ),
              ],
            ),
            RpgFormSection(
              title: 'Atributos',
              subtitle: 'máximo +6',
              icon: Icons.tune,
              children: [
                RpgFieldGrid(
                  minColumnWidth: 126,
                  children: [
                    for (final entry in attributeControllers.entries)
                      TextField(
                        controller: entry.value,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: entry.key),
                      ),
                  ],
                ),
              ],
            ),
            RpgFormSection(
              title: 'Perícias',
              subtitle: 'máximo +3',
              icon: Icons.checklist,
              children: [
                RpgFieldGrid(
                  minColumnWidth: 142,
                  children: [
                    for (final entry in skillControllers.entries)
                      TextField(
                        controller: entry.value,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: entry.key),
                      ),
                  ],
                ),
              ],
            ),
            RpgFormSection(
              title: 'Acessórios',
              subtitle: 'limite de 2 especiais',
              icon: Icons.diamond,
              children: [
                RpgFieldGrid(
                  minColumnWidth: 230,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: accessoryOne,
                      isExpanded: true,
                      items: _stringDropdownItems(['', ...accessoryOptions]),
                      onChanged: (value) =>
                          setState(() => accessoryOne = value ?? accessoryOne),
                      decoration: const InputDecoration(
                        labelText: 'Acessório especial 1',
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: accessoryTwo,
                      isExpanded: true,
                      items: _stringDropdownItems(['', ...accessoryOptions]),
                      onChanged: (value) =>
                          setState(() => accessoryTwo = value ?? accessoryTwo),
                      decoration: const InputDecoration(
                        labelText: 'Acessório especial 2',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          RpgButton(
            label: 'Cancelar',
            onPressed: () => Navigator.of(context).pop(),
          ),
          RpgButton(
            label: existing == null ? 'Criar' : 'Salvar',
            icon: Icons.save,
            variant: RpgButtonVariant.primary,
            onPressed: () {
              final attributes = _parseStats(attributeControllers);
              final skills = _parseStats(skillControllers);
              final invalidAttribute = _firstInvalidStat(attributes, 6);
              final invalidSkill = _firstInvalidStat(skills, 3);
              if (invalidAttribute != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$invalidAttribute nao pode passar de +6.'),
                  ),
                );
                return;
              }
              if (invalidSkill != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$invalidSkill nao pode passar de +3.'),
                  ),
                );
                return;
              }
              final accessories = [
                accessoryOne.trim(),
                accessoryTwo.trim(),
              ].where((item) => item.isNotEmpty).toList();
              final changingToMage =
                  existing != null &&
                  !_sameOptionName(existing.characterClass, characterClass) &&
                  _sameOptionName(characterClass, 'Mago');
              if (changingToMage &&
                  mageSpellSelections.length < existing.level - 1) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Escolha as magias adquiridas pelo mago.'),
                  ),
                );
                return;
              }
              final hasShield = shieldOptions.any(
                (item) => _sameOptionName(item, secondaryItem),
              );
              final maxHp = 10 + (attributes['Vigor'] ?? 0);
              final parsedCurrentHp =
                  (int.tryParse(currentHp.text) ?? existing?.currentHp ?? maxHp)
                      .clamp(0, maxHp)
                      .toInt();
              final character = CharacterSheet(
                id:
                    existing?.id ??
                    'char-${DateTime.now().microsecondsSinceEpoch}',
                name: name.text.trim().isEmpty
                    ? 'Novo personagem'
                    : name.text.trim(),
                race: race,
                characterClass: characterClass,
                level: existing?.level ?? 1,
                concept: concept.text,
                attributes: attributes,
                skills: skills,
                currentHp: parsedCurrentHp,
                armor: armor,
                hasShield: hasShield,
                mainWeapon: mainWeapon,
                secondaryItem: secondaryItem,
                accessories: accessories,
                powers: existing?.powers ?? const [],
                inventory: existing?.inventory ?? const [],
                statuses: existing?.statuses ?? const [],
                coins: (int.tryParse(coins.text) ?? existing?.coins ?? 5)
                    .clamp(0, 999999)
                    .toInt(),
                ownerName: existing?.ownerName,
                archived: existing?.archived ?? false,
              );
              if (existing == null) {
                context.read<RpgSessionController>().addCharacter(character);
              } else {
                context.read<RpgSessionController>().updateCharacter(
                  character,
                  selectedMageSpellIds: mageSpellSelections.values
                      .whereType<String>()
                      .toList(),
                );
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    ),
  );
}
