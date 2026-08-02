import 'package:supabase_flutter/supabase_flutter.dart';

/// Singleton access to the Supabase client.
class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;

  static GoTrueClient get auth => client.auth;

  static SupabaseStorageClient get storage => client.storage;

  static User? get currentUser => auth.currentUser;

  static bool get isAuthenticated => currentUser != null;

  static String? get userId => currentUser?.id;

  /// Get a table query builder.
  static SupabaseQueryBuilder from(String table) => client.from(table);
}
