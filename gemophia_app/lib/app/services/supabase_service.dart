import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gemophia_app/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gemophia_app/app/core/config/env_config.dart';
import 'package:file_picker/file_picker.dart';

class SupabaseService extends GetxController {
  static SupabaseService get to => Get.find();

  late final SupabaseClient _client;

  final _user =
      User(
        aud: '',
        userMetadata: Map(),
        updatedAt: null,
        id: '0',
        email: null,
        appMetadata: Map(),
        createdAt: '',
      ).obs;

  set user(User value) => _user.value = value;
  User get user => _user.value;

  @override
  void onInit() async {
    super.onInit();
    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
    );
    _client = Supabase.instance.client;

    // 인증 상태 변화 수신
    _client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;
      if (session != null) {
        // 로그인 성공
        print('로그인 성공: ${session.user.email}');
        user = session.user;
        Get.offAllNamed(Routes.HOME);
        // Navigator.of(context).pushReplacement(
        //   MaterialPageRoute(builder: (_) => HomePage()),
        // );
      }
    });
  }

  SupabaseClient get client => _client;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<bool> login(String email) async {
    try {
      await _client.auth.signInWithOtp(email: email);
      return true;
    } catch (e) {
      // throw Exception('Login failed: $e');
      return false;
    }
  }

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

  // Insert (단일 레코드 삽입, 응답 없음)
  Future<void> insert({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _client.from(table).insert(data);
    } catch (e) {
      throw Exception('Insert failed: $e');
    }
  }

  // Insert and Return (단일 레코드 삽입 후 반환)
  Future<Map<String, dynamic>> insertAndReturn({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _client.from(table).insert(data).select().single();
      return response;
    } catch (e) {
      throw Exception('Insert and return failed: $e');
    }
  }

  // Insert Many (여러 레코드 일괄 삽입)
  Future<List<Map<String, dynamic>>> insertMany({
    required String table,
    required List<Map<String, dynamic>> dataList,
  }) async {
    try {
      final response = await _client.from(table).insert(dataList).select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Insert many failed: $e');
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

  // Pick and Upload File (파일 선택 및 업로드)
  Future<String?> pickAndUploadFile({
    String bucket = 'AI_conversation_data/ai',
    List<String>? allowedExtensions,
    FileType type = FileType.any,
    String? conversationId,
    String? description,
  }) async {
    await EasyLoading.show(status: 'loading...');
    try {
      // 인증 확인
      if (currentUser == null) {
        throw Exception('User is not authenticated. Please login first.');
      }

      // 파일 선택
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
      );

      if (result == null || result.files.single.path == null) {
        return null; // 사용자가 파일 선택을 취소함
      }

      final file = File(result.files.single.path!);
      final originalName = result.files.single.name;
      final extension = originalName.split('.').last;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${timestamp}_${currentUser!.id}.${extension}';
      final fileSize = await file.length();

      // MIME 타입 추정
      String? mimeType;
      if (result.files.single.extension != null) {
        final ext = result.files.single.extension!.toLowerCase();
        if (ext == 'pdf') {
          mimeType = 'application/pdf';
        } else if (ext == 'jpg' || ext == 'jpeg') {
          mimeType = 'image/jpeg';
        } else if (ext == 'png') {
          mimeType = 'image/png';
        } else if (ext == 'txt') {
          mimeType = 'text/plain';
        } else if (ext == 'doc') {
          mimeType = 'application/msword';
        } else if (ext == 'docx') {
          mimeType =
              'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
        }
      }

      // 파일 업로드
      await _client.storage
          .from(bucket)
          .upload(
            fileName,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // Get public URL
      final publicUrl = _client.storage.from(bucket).getPublicUrl(fileName);

      // ai_conversation_files 테이블에 데이터 삽입
      await insert(
        table: 'ai_conversation_files',
        data: {
          'user_id': currentUser!.id,
          'file_name': fileName,
          'original_file_name': originalName,
          'file_url': publicUrl,
          'file_size': fileSize,
          'mime_type': mimeType,
          'file_extension': extension,
          'bucket_name': bucket,
          if (conversationId != null) 'conversation_id': conversationId,
          if (description != null) 'description': description,
        },
      );
      await EasyLoading.dismiss();
      return publicUrl;
    } catch (e) {
      await EasyLoading.dismiss();
      throw Exception('File pick and upload failed: $e');
    }
  }

  // File Upload to Storage
  Future<String> uploadFile({
    required String filePath,
    required String fileName,
    String bucket = 'AI_conversation_data',
  }) async {
    try {
      final file = File(filePath);
      await _client.storage
          .from(bucket)
          .upload(
            fileName,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // Get public URL
      final publicUrl = _client.storage.from(bucket).getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      throw Exception('File upload failed: $e');
    }
  }

  // Upload File from Bytes
  Future<String> uploadFileFromBytes({
    required Uint8List bytes,
    required String fileName,
    String bucket = 'AI_conversation_data',
    String? mimeType,
  }) async {
    try {
      await _client.storage
          .from(bucket)
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(
              cacheControl: '3600',
              upsert: false,
              contentType: mimeType,
            ),
          );

      // Get public URL
      final publicUrl = _client.storage.from(bucket).getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      throw Exception('File upload from bytes failed: $e');
    }
  }

  // Delete File from Storage
  Future<void> deleteFile({
    required String fileName,
    String bucket = 'AI_conversation_data',
  }) async {
    try {
      await _client.storage.from(bucket).remove([fileName]);
    } catch (e) {
      throw Exception('File deletion failed: $e');
    }
  }

  // List Files in Bucket
  Future<List<FileObject>> listFiles({
    String bucket = 'AI_conversation_data',
    String? path,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final files = await _client.storage
          .from(bucket)
          .list(
            path: path,
            searchOptions: SearchOptions(limit: limit, offset: offset),
          );
      return files;
    } catch (e) {
      throw Exception('List files failed: $e');
    }
  }

  // Download File
  Future<List<int>> downloadFile({
    required String fileName,
    String bucket = 'AI_conversation_data',
  }) async {
    try {
      final bytes = await _client.storage.from(bucket).download(fileName);
      return bytes;
    } catch (e) {
      throw Exception('File download failed: $e');
    }
  }

  // Get Public URL for File
  String getPublicUrl({
    required String fileName,
    String bucket = 'AI_conversation_data',
  }) {
    return _client.storage.from(bucket).getPublicUrl(fileName);
  }
}
