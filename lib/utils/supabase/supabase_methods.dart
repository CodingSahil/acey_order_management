import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseMethods {
  static Future<List<T>> getFromList<T>({required String tableKey, required T Function(Map<String, dynamic> json) fromJson}) async {
    final future = await Supabase.instance.client.from(tableKey).select();
    return future.map((e) => fromJson(e)).toList();
  }
}
