import '../../domain/domain.dart';
import 'official_name_matcher.dart';

class CharacterProgressionService {
  const CharacterProgressionService._();

  static ClassProgressionEntry? progressionFor({
    required List<ClassProgressionEntry> progression,
    required String characterClass,
    required int level,
  }) {
    return OfficialNameMatcher.firstWhereOrNull(
      progression,
      (entry) =>
          OfficialNameMatcher.same(entry.characterClass, characterClass) &&
          entry.level == level,
    );
  }
}
