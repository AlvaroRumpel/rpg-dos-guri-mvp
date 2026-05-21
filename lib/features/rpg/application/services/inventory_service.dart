import '../../domain/domain.dart';
import 'official_name_matcher.dart';

class InventoryService {
  const InventoryService._();

  static ItemTemplate? findItemByName(
    Iterable<ItemTemplate> items,
    String name,
  ) {
    return OfficialNameMatcher.firstWhereOrNull(
      items,
      (item) => OfficialNameMatcher.same(item.name, name),
    );
  }
}
