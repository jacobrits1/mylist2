import 'package:mylist2/data/models/category.dart';
import 'package:mylist2/data/sources/local/database_helper.dart';

class CategoryRepository {
  final DatabaseHelper _databaseHelper;

  CategoryRepository({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper();

  Future<List<Category>> getAllCategories() async {
    return await _databaseHelper.getAllCategories();
  }

  Future<Category?> getCategoryById(int id) async {
    return await _databaseHelper.getCategoryById(id);
  }

  Future<int> createCategory(Category category) async {
    return await _databaseHelper.insertCategory(category);
  }

  Future<int> updateCategory(Category category) async {
    return await _databaseHelper.updateCategory(category);
  }

  Future<int> deleteCategory(int id) async {
    return await _databaseHelper.deleteCategory(id);
  }
} 