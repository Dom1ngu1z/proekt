class SupabaseConfig {
  static const String url = 'https://sycifluvklfiktwlkjkm.supabase.co';
  static const String anonKey = 'sb_publishable_HR0NOXsUCVQUepmLxVTyiw_nlLHuUt7';

  static bool get isConfigured {
    // Проверяем, что поля не пустые и URL похож на правду
    return url.isNotEmpty &&
        url.contains('supabase.co') &&
        anonKey.isNotEmpty &&
        anonKey != 'YOUR_ANON_KEY'; // Проверка на дефолтный плейсхолдер
  }
}

