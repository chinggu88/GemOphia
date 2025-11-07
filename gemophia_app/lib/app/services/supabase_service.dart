import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gemophia_app/app/core/config/env_config.dart';

class SupabaseService extends GetxController {
  static SupabaseService get to => Get.find();

  late final SupabaseClient _client;

  @override
  void onInit() async {
    super.onInit();
    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  SupabaseClient get client => _client;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Create
  Future<Map<String, dynamic>> create({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _client.from(table).insert(data).select().single();
      return response;
    } catch (e) {
      throw Exception('Create failed: $e');
    }
  }

  // Read All
  Future<List<Map<String, dynamic>>> readAll({
    required String table,
    String columns = '*',
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    try {
      dynamic query = _client.from(table).select(columns);

      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Read failed: $e');
    }
  }

  // Read with Filter
  Future<List<Map<String, dynamic>>> readWithFilter({
    required String table,
    required Map<String, dynamic> filters,
    String columns = '*',
    String? orderBy,
    bool ascending = true,
  }) async {
    try {
      dynamic query = _client.from(table).select(columns);

      filters.forEach((key, value) {
        query = query.eq(key, value);
      });

      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Read with filter failed: $e');
    }
  }

  // Read Single
  Future<Map<String, dynamic>?> readSingle({
    required String table,
    required Map<String, dynamic> match,
    String columns = '*',
  }) async {
    try {
      var query = _client.from(table).select(columns);

      match.forEach((key, value) {
        query = query.eq(key, value);
      });

      final response = await query.maybeSingle();
      return response;
    } catch (e) {
      throw Exception('Read single failed: $e');
    }
  }

  // Update
  Future<List<Map<String, dynamic>>> updateData({
    required String table,
    required Map<String, dynamic> data,
    required Map<String, dynamic> match,
  }) async {
    try {
      var query = _client.from(table).update(data);

      match.forEach((key, value) {
        query = query.eq(key, value);
      });

      final response = await query.select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Update failed: $e');
    }
  }

  // Delete
  Future<void> delete({
    required String table,
    required Map<String, dynamic> match,
  }) async {
    try {
      var query = _client.from(table).delete();

      match.forEach((key, value) {
        query = query.eq(key, value);
      });

      await query;
    } catch (e) {
      throw Exception('Delete failed: $e');
    }
  }

  // Realtime Subscribe
  RealtimeChannel subscribe({
    required String table,
    required PostgresChangeEvent event,
    required void Function(PostgresChangePayload payload) callback,
  }) {
    final channel = _client.channel('public:$table');

    channel.onPostgresChanges(
      event: event,
      schema: 'public',
      table: table,
      callback: callback,
    );

    channel.subscribe();
    return channel;
  }

  // Unsubscribe
  Future<void> unsubscribe(RealtimeChannel channel) async {
    await _client.removeChannel(channel);
  }
}
