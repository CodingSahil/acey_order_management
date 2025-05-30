import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseMethods {
  static Future<List<T>> getFromList<T>({required String tableKey, required T Function(Map<String, dynamic> json) fromJson}) async {
    final future = await Supabase.instance.client.from(tableKey).select();
    return future.map((e) => fromJson(e)).toList();
  }

  static Future<void> createObjectInTable({required String tableKey, required Map<String, dynamic> request}) async {
    await Supabase.instance.client.from(tableKey).insert(request);
    log('createObjectInTable SupabaseMethods');
  }

  static Future<void> updateObjectInTable({required String tableKey, required Map<String, dynamic> request, required num id}) async {
    await Supabase.instance.client.from(tableKey).update(request).eq('id', id);
    log('updateObjectInTable SupabaseMethods');
  }
}
