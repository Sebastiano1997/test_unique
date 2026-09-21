import '../../../dependencies/services/ISaveLoad.dart';
import '../model/PageOutModels.dart';

class PageOutDal {
  PageOutDal()
      : saveLoadJson = SaveLoadJson<PageOutDm>(
          keyToSave: _storageKey,
          toJson: (page) => page.toJson(),
          fromJson: PageOutDm.fromJson,
        );

  static const String _storageKey = 'page_out';

  final SaveLoadJson<PageOutDm> saveLoadJson;

  Future<void> save(PageOutDm dm) => saveLoadJson.save(dm);

  Future<PageOutDm> load() async {
    return await saveLoadJson.load() ?? PageOutDm();
  }
}
