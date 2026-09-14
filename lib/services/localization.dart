import 'package:flutter/foundation.dart';

enum AppLanguage {
  tr,
  en,
}

class LocalizationService extends ChangeNotifier {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  AppLanguage _currentLanguage = AppLanguage.tr;

  AppLanguage get currentLanguage => _currentLanguage;
  bool get isTr => _currentLanguage == AppLanguage.tr;

  void toggleLanguage() {
    _currentLanguage =
        _currentLanguage == AppLanguage.tr ? AppLanguage.en : AppLanguage.tr;
    notifyListeners();
  }

  void setLanguage(AppLanguage lang) {
    if (_currentLanguage != lang) {
      _currentLanguage = lang;
      notifyListeners();
    }
  }

  String tr(String key) {
    final map = _currentLanguage == AppLanguage.tr ? _trMap : _enMap;
    return map[key] ?? key;
  }

  static const Map<String, String> _trMap = {
    'app_title': 'MystCrochet Planner',
    'app_subtitle': 'Granny Square Proje & Renk Planlayıcı',
    'new_project': 'Yeni Proje Başlat',
    'recent_projects': 'Kayıtlı Projelerim',
    'no_recent_projects': 'Henüz kaydedilmiş bir projeniz yok. Yukarıdan yeni bir proje başlatın!',
    'template_sweater_title': 'Kazak & Hırka',
    'template_sweater_desc': 'Ön, arka ve kollar için ayrılmış granny square montaj şablonu.',
    'template_blanket_title': 'Battaniye & Örtü',
    'template_blanket_desc': 'Koltuk şalı, bebek battaniyesi veya yatak örtüsü için NxM ızgara.',
    'template_tote_title': '13 Kareli Tote Çanta',
    'template_tote_desc': 'Tığ işinin en sevilen klasik origami çanta açılım şablonu.',
    'template_custom_title': 'Özel Boyutlu Izgara',
    'template_custom_desc': 'Satır ve sütun sayısını serbestçe belirleyebileceğiniz çalışma alanı.',
    'create_project_dialog_title': 'Proje Ayarları',
    'project_name': 'Proje Adı',
    'rows': 'Satır Sayısı',
    'cols': 'Sütun Sayısı',
    'create_btn': 'Projeyi Başlat',
    'cancel_btn': 'İptal',
    'save_btn': 'Kaydet',
    'saved_success': 'Proje başarıyla kaydedildi!',
    'export_btn': 'Dışa Aktar',
    'export_png': 'PNG Görseli Olarak İndir',
    'export_json': 'Proje Dosyası (JSON) İndir',
    'import_json': 'JSON Proje Yükle',
    'tally_summary': 'Motif Sayacı & Özet',
    'motif_library': 'Motif Kütüphanem',
    'new_motif': 'Yeni Motif Tasarla',
    'edit_motif': 'Motifi Düzenle',
    'delete_motif': 'Motifi Sil',
    'active_motif': 'Aktif Seçili Motif',
    'brush_tool': 'Fırça (Tıkla/Sürükle Yerleştir)',
    'fill_all': 'Tümünü Doldur',
    'fill_empty': 'Boşları Doldur',
    'shuffle_random': 'Rastgele Dağıt (Shuffle)',
    'clear_section': 'Bölümü Temizle',
    'total_squares': 'Toplam Kare',
    'filled_squares': 'Dolu Kare',
    'empty_squares': 'Boş Kalan',
    'completion_rate': 'Tamamlanma Oranı',
    'motif_tally_breakdown': 'Örülmesi Gereken Motif Adetleri',
    'units': 'adet',
    'round': 'Tur',
    'round_center': 'Tur 1 (Merkez)',
    'round_border': 'Tur 4 (Çerçeve)',
    'select_color': 'İplik Rengi Seç',
    'motif_type': 'Motif Modeli',
    'motif_name': 'Motif Adı',
    'section_front': 'Ön Gövde',
    'section_back': 'Arka Gövde',
    'section_left_sleeve': 'Sol Kol',
    'section_right_sleeve': 'Sağ Kol',
    'section_blanket': 'Battaniye Izgarası',
    'section_tote': 'Çanta Katlama Açılımı',
    'section_custom': 'Çalışma Izgarası',
    'delete_project': 'Projeyi Sil',
    'delete_confirm': 'Bu projeyi silmek istediğinizden emin misiniz?',
    'delete': 'Sil',
    'quick_size_baby': 'Bebek Battaniyesi (5x6)',
    'quick_size_throw': 'Koltuk Şalı (6x8)',
    'quick_size_queen': 'Büyük Boy (8x10)',
    'upload_photo': 'Fotoğraf Çek / Yükle',
    'take_photo': 'Kamerayla Çek',
    'pick_gallery': 'Galeriden / Dosyadan Seç',
    'photo_square': 'Fotoğraflı Motif',
    'crop_title': 'Motifi Kırp & Hizala',
    'crop_instructions': 'Motifi 1:1 kareye hizalayın. Kaydırabilir, yakınlaştırabilir ve döndürebilirsiniz.',
    'rotate_btn': 'Döndür (90°)',
    'zoom_label': 'Yakınlaştır',
    'crop_confirm': 'Kırp ve Motifi Kaydet',
    'photo_motif_name_default': 'Gerçek Motifim',
    'photo_loading_error': 'Fotoğraf yüklenirken bir hata oluştu.',
  };

  static const Map<String, String> _enMap = {
    'app_title': 'MystCrochet Planner',
    'app_subtitle': 'Granny Square Project & Colorway Planner',
    'new_project': 'Start New Project',
    'recent_projects': 'Saved Projects',
    'no_recent_projects': 'No saved projects yet. Start a new project above!',
    'template_sweater_title': 'Sweater & Cardigan',
    'template_sweater_desc': 'Garment assembly template with Front, Back, and Sleeves.',
    'template_blanket_title': 'Blanket & Throw',
    'template_blanket_desc': 'NxM grid for baby blankets, throws, or bedspreads.',
    'template_tote_title': '13-Square Tote Bag',
    'template_tote_desc': 'Classic origami granny square fold pattern.',
    'template_custom_title': 'Custom Grid',
    'template_custom_desc': 'Freeform canvas with custom row and column counts.',
    'create_project_dialog_title': 'Project Settings',
    'project_name': 'Project Name',
    'rows': 'Number of Rows',
    'cols': 'Number of Columns',
    'create_btn': 'Start Project',
    'cancel_btn': 'Cancel',
    'save_btn': 'Save',
    'saved_success': 'Project saved successfully!',
    'export_btn': 'Export',
    'export_png': 'Download PNG Image',
    'export_json': 'Download Project File (JSON)',
    'import_json': 'Import JSON Project',
    'tally_summary': 'Motif Tally & Summary',
    'motif_library': 'Motif Library',
    'new_motif': 'Design New Motif',
    'edit_motif': 'Edit Motif',
    'delete_motif': 'Delete Motif',
    'active_motif': 'Active Motif',
    'brush_tool': 'Brush (Click/Drag to Place)',
    'fill_all': 'Fill All',
    'fill_empty': 'Fill Empty',
    'shuffle_random': 'Shuffle Colors',
    'clear_section': 'Clear Section',
    'total_squares': 'Total Squares',
    'filled_squares': 'Filled Squares',
    'empty_squares': 'Remaining',
    'completion_rate': 'Completion',
    'motif_tally_breakdown': 'Squares Needed to Crochet',
    'units': 'squares',
    'round': 'Round',
    'round_center': 'Round 1 (Center)',
    'round_border': 'Round 4 (Border)',
    'select_color': 'Select Yarn Color',
    'motif_type': 'Motif Style',
    'motif_name': 'Motif Name',
    'section_front': 'Front Body',
    'section_back': 'Back Body',
    'section_left_sleeve': 'Left Sleeve',
    'section_right_sleeve': 'Right Sleeve',
    'section_blanket': 'Blanket Grid',
    'section_tote': 'Tote Fold Layout',
    'section_custom': 'Custom Canvas',
    'delete_project': 'Delete Project',
    'delete_confirm': 'Are you sure you want to delete this project?',
    'delete': 'Delete',
    'quick_size_baby': 'Baby Blanket (5x6)',
    'quick_size_throw': 'Throw Blanket (6x8)',
    'quick_size_queen': 'Large Bedspread (8x10)',
    'upload_photo': 'Take / Upload Photo',
    'take_photo': 'Take with Camera',
    'pick_gallery': 'Choose from Gallery / Files',
    'photo_square': 'Photo Square',
    'crop_title': 'Crop & Align Motif',
    'crop_instructions': 'Align your square within the 1:1 box. Pan, zoom, and rotate as needed.',
    'rotate_btn': 'Rotate (90°)',
    'zoom_label': 'Zoom',
    'crop_confirm': 'Crop and Save Motif',
    'photo_motif_name_default': 'My Real Square',
    'photo_loading_error': 'Failed to load photo.',
  };
}

/// Global convenience getter
String t(String key) => LocalizationService().tr(key);
