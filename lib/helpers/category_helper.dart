import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String categoriesTable = "categoriesTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";

class CategoryHelper {
  static final CategoryHelper _instance = CategoryHelper.internal();

  factory CategoryHelper() => _instance;

  CategoryHelper.internal();

  Database _db;

  Future<Database> get db async {
    if(_db != null) {
      return _db;
    }
    else {
      _db = await initDb();

      return _db;
    }
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "categories.db");

    return await openDatabase(path, version: 1, onCreate: (Database db, int newerVersion) async {
      await db.execute(
        "CREATE TABLE $categoriesTable("
          "$idColumn INTEGER PRIMARY KEY, "
          "$nameColumn TEXT)"
        );
    });

  }

  Future<CategoryLink> saveTheme(CategoryLink categoryLink) async {
    Database dbCategory = await db;
    categoryLink.id = await dbCategory.insert(categoriesTable, categoryLink.toMap());

    return categoryLink;
  }

  Future close() async {
    Database dbCategory = await db;
    dbCategory.close();
  }
}

class CategoryLink {
  int id;
  String name;

  CategoryLink();

  CategoryLink.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: name
    };

    if(id != null) {
      map[idColumn] = id;
    }

    return map;
  }

  @override
  String toString() {
    return "Category: {id: $id, name: $name}";
  }
}