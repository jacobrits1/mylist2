import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mylist2/data/repositories/category_repository.dart';
import 'package:mylist2/presentation/blocs/category/category_event.dart';
import 'package:mylist2/presentation/blocs/category/category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _categoryRepository;

  CategoryBloc({required CategoryRepository categoryRepository})
      : _categoryRepository = categoryRepository,
        super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      emit(CategoryLoading());
      final categories = await _categoryRepository.getAllCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onAddCategory(
    AddCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      if (state is CategoryLoaded) {
        final currentState = state as CategoryLoaded;
        await _categoryRepository.createCategory(event.category);
        final categories = await _categoryRepository.getAllCategories();
        emit(CategoryLoaded(categories));
      }
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      if (state is CategoryLoaded) {
        await _categoryRepository.updateCategory(event.category);
        final categories = await _categoryRepository.getAllCategories();
        emit(CategoryLoaded(categories));
      }
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      if (state is CategoryLoaded) {
        await _categoryRepository.deleteCategory(event.categoryId);
        final categories = await _categoryRepository.getAllCategories();
        emit(CategoryLoaded(categories));
      }
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
} 