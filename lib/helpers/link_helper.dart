import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String linksTable = "linksTable";
final String linksTableBk = "linksTableBk"; //utilizada apenas no onUpgrade
final String idColumn = "idColumn";
final String titleColumn = "titleColumn";
final String linkColumn = "linkColumn";
final String obsColumn = "obsColumn";
final String categoryColumn = "categoryColumn";
final String themeColumn = "themeColumn"; //renomeada para categoryColumn

class LinkHelper {
  static final LinkHelper _instance = LinkHelper.internal();

  factory LinkHelper() => _instance;

  LinkHelper.internal();

  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();

      return _db;
    }
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "links.db");

    return await openDatabase(path, version: 2,
        onCreate: (Database db, int newerVersion) async {
      await db.execute("CREATE TABLE $linksTable("
          "$idColumn INTEGER PRIMARY KEY, "
          "$titleColumn TEXT, "
          "$linkColumn TEXT, "
          "$obsColumn TEXT, "
          "$categoryColumn TEXT)");
    }, onUpgrade: (Database db, int oldV, int newV) async {
      if (oldV < newV) {
        for (var i = 0; i < scriptOnUpgrade.length; i++) {
          await db.execute(scriptOnUpgrade[
              i]); //necessário fazer dessa forma por causa da versão do sqlite 3.22
        }
      }
    });
  }

  final scriptOnUpgrade = [
    "ALTER TABLE $linksTable RENAME TO $linksTableBk;",
    '''
      CREATE TABLE $linksTable(
        $idColumn INTEGER PRIMARY KEY,
        $titleColumn TEXT,
        $linkColumn TEXT,
        $obsColumn TEXT,
        $categoryColumn TEXT)
    ''',
    '''
      INSERT INTO $linksTable($idColumn,$titleColumn,$linkColumn,$obsColumn,$categoryColumn) SELECT $idColumn,$titleColumn,$linkColumn,$obsColumn,$themeColumn FROM $linksTableBk;
    ''',
    "DROP TABLE $linksTableBk;"
  ];

  Future<Link> saveLink(Link link) async {
    Database dbLink = await db;
    link.id = await dbLink.insert(linksTable, link.toMap());

    return link;
  }

  Future<Link> getLink(int id) async {
    Database dbLink = await db;
    List<Map> maps = await dbLink.query(linksTable,
        columns: [idColumn, titleColumn, linkColumn, obsColumn, categoryColumn],
        where: "$idColumn = ?",
        whereArgs: [id]);

    if (maps.length > 0) {
      return Link.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteLink(int id) async {
    Database dbLink = await db;
    return await dbLink
        .delete(linksTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  Future<int> updateLink(Link link) async {
    Database dbLink = await db;
    return await dbLink.update(linksTable, link.toMap(),
        where: "$idColumn = ?", whereArgs: [link.id]);
  }

  Future<List> getAllLinks() async {
    Database dbLink = await db;
    List listMap = await dbLink.rawQuery("SELECT * FROM $linksTable");
    List<Link> listLinks = [];

    for (Map m in listMap) {
      listLinks.add(Link.fromMap(m));
    }

    return listLinks;
  }

  Future close() async {
    Database dbLink = await db;
    dbLink.close();
  }
}

class Link {
  int id;
  String title;
  String link;
  String obs;
  String category;

  Link();

  Link.fromMap(Map map) {
    id = map[idColumn];
    title = map[titleColumn];
    link = map[linkColumn];
    obs = map[obsColumn];
    category = map[categoryColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      titleColumn: title,
      linkColumn: link,
      obsColumn: obs,
      categoryColumn: category
    };
    if (id != null) {
      map[idColumn] = id;
    }

    return map;
  }

  @override
  String toString() {
    return "Link(id: $id, title: $title, link: $link, obs: $obs, theme: $category)";
  }
}
