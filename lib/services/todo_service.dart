import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo_model.dart';
import 'storage_service.dart';

/// 待办事项服务（本地存储版本，使用 Mock 数据）
class TodoService {
  static final TodoService _instance = TodoService._internal();
  factory TodoService() => _instance;
  TodoService._internal();

  final StorageService _storageService = StorageService();
  static const String _todosKey = 'todos_list';

  List<TodoModel> _cachedTodos = [];

  /// 初始化服务并加载数据
  Future<void> init() async {
    await _loadTodos();
  }

  /// 从本地加载待办事项
  Future<void> _loadTodos() async {
    try {
      await _storageService.init();
      final SharedPreferences? prefs = await SharedPreferences.getInstance();
      if (prefs == null) return;

    final todosJson = prefs.getString(_todosKey);
    if (todosJson != null) {
      final List<dynamic> decoded = jsonDecode(todosJson);
      _cachedTodos = decoded.map((json) => TodoModel.fromJson(json)).toList();
    } else {
      // 如果没有数据，创建一些 Mock 数据
      _cachedTodos = _generateMockTodos();
      await _saveTodos();
    }
    } catch (e) {
      // 加载失败时使用mock数据
      _cachedTodos = _generateMockTodos();
    }
  }

  /// 保存待办事项到本地
  Future<void> _saveTodos() async {
    try {
      await _storageService.init();
      final SharedPreferences? prefs = await SharedPreferences.getInstance();
      if (prefs == null) return;

      final todosJson = jsonEncode(_cachedTodos.map((todo) => todo.toJson()).toList());
      await prefs.setString(_todosKey, todosJson);
    } catch (e) {
      // 保存失败时忽略错误
    }
  }  /// 生成 Mock 数据
  List<TodoModel> _generateMockTodos() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return [
      TodoModel(
        id: '1',
        title: '早上服用降压药',
        description: '每天早上8点服用',
        dateTime: today.add(const Duration(hours: 8)),
        type: TodoType.medication,
        familyId: 'family_1',
        careReceiverId: 'care_receiver_1',
      ),
      TodoModel(
        id: '2',
        title: '上午锻炼',
        description: '公园散步30分钟',
        dateTime: today.add(const Duration(hours: 9)),
        type: TodoType.exercise,
        familyId: 'family_1',
        careReceiverId: 'care_receiver_1',
      ),
      TodoModel(
        id: '3',
        title: '午餐提醒',
        description: '记得少盐少油',
        dateTime: today.add(const Duration(hours: 12)),
        type: TodoType.meal,
        familyId: 'family_1',
        careReceiverId: 'care_receiver_1',
      ),
      TodoModel(
        id: '4',
        title: '下午医院复查',
        description: '心内科，带上病历本',
        dateTime: today.add(const Duration(hours: 14)),
        type: TodoType.appointment,
        familyId: 'family_1',
        careReceiverId: 'care_receiver_1',
      ),
      TodoModel(
        id: '5',
        title: '晚上服用降压药',
        description: '每天晚上8点服用',
        dateTime: today.add(const Duration(hours: 20)),
        type: TodoType.medication,
        familyId: 'family_1',
        careReceiverId: 'care_receiver_1',
      ),
      // 明天的待办
      TodoModel(
        id: '6',
        title: '早上服用降压药',
        description: '每天早上8点服用',
        dateTime: today.add(const Duration(days: 1, hours: 8)),
        type: TodoType.medication,
        familyId: 'family_1',
        careReceiverId: 'care_receiver_1',
      ),
      TodoModel(
        id: '7',
        title: '参加社区活动',
        description: '太极拳学习班',
        dateTime: today.add(const Duration(days: 1, hours: 10)),
        type: TodoType.activity,
        familyId: 'family_1',
        careReceiverId: 'care_receiver_1',
      ),
    ];
  }

  /// 获取指定日期的待办事项
  Future<List<TodoModel>> getTodosByDate(DateTime date, String familyId, String careReceiverId) async {
    if (_cachedTodos.isEmpty) {
      await _loadTodos();
    }

    final targetDate = DateTime(date.year, date.month, date.day);
    return _cachedTodos.where((todo) {
      final todoDate = DateTime(todo.dateTime.year, todo.dateTime.month, todo.dateTime.day);
      return todoDate.isAtSameMomentAs(targetDate) &&
          todo.familyId == familyId &&
          todo.careReceiverId == careReceiverId;
    }).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  /// 创建待办事项
  Future<TodoModel> createTodo(TodoModel todo) async {
    _cachedTodos.add(todo);
    await _saveTodos();
    return todo;
  }

  /// 更新待办事项
  Future<TodoModel> updateTodo(TodoModel todo) async {
    final index = _cachedTodos.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      _cachedTodos[index] = todo.copyWith(updatedAt: DateTime.now());
      await _saveTodos();
      return _cachedTodos[index];
    }
    throw Exception('待办事项不存在');
  }

  /// 切换待办事项完成状态
  Future<TodoModel> toggleTodoComplete(String todoId) async {
    final index = _cachedTodos.indexWhere((t) => t.id == todoId);
    if (index != -1) {
      _cachedTodos[index] = _cachedTodos[index].copyWith(
        isCompleted: !_cachedTodos[index].isCompleted,
        updatedAt: DateTime.now(),
      );
      await _saveTodos();
      return _cachedTodos[index];
    }
    throw Exception('待办事项不存在');
  }

  /// 删除待办事项
  Future<void> deleteTodo(String todoId) async {
    _cachedTodos.removeWhere((t) => t.id == todoId);
    await _saveTodos();
  }

  /// 获取所有待办事项
  Future<List<TodoModel>> getAllTodos() async {
    if (_cachedTodos.isEmpty) {
      await _loadTodos();
    }
    return _cachedTodos;
  }
}
