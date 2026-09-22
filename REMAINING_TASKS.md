# MystCrochet Planner - Kalan Görevler ve Yol Haritası (Remaining Tasks & Roadmap)

Bu doküman, **MystCrochet Planner** projesinin Vikunja üzerindeki görev durumunu, tamamlanan modülleri ve gelecekte yapılması gereken kalan görevleri açıklayan teknik özettir.

---

## 📌 Vikunja Görev Özeti (Task Overview)

| Görev ID | İndeks | Başlık / Açıklama | Durum |
| :--- | :---: | :--- | :---: |
| 52 | **#1** | `mystcrochet projesi hazirla` | ✅ Tamamlandı |
| 53 | **#2** | `granny square ile yaptigimiz projelerin tasarlanacagi ekrani hazirla...` | ✅ Tamamlandı |
| 54 | **#3** | `kazak projesi icinde arka govde, sol kol vb de dille degisken olsun.` | ✅ Tamamlandı |
| 55 | **#4** | `kazak projesi icindeki bolgeler(kollar, govdeler) boyutu duzenlenebilir olsun. granny square boyutlari girince kol ve govde boyutlarini hesaplasin` | ✅ Tamamlandı |
| 56 | **#5** | `fotoyla yuklenen kareler icin kisisel kutuphane olustur. dbde user icin kaydet` | ✅ Tamamlandı |
| 57 | **#6** | `proje tasarlama ekrani ekle, grid olmak zorunda olmasin, serbest form kareler ile proje kaydedilebilsin.` | ✅ Tamamlandı |
| 58 | **#7** | `custom projeleri dbye ekle` | ✅ Tamamlandı |
| 59 | **#8** | `kare disinda altigen, besgen ve ucgen icin de destek ekle` | ✅ Tamamlandı |
| 60 | **#9** | `mystcrochet-app te cizip backend dbde kaydettigimiz tasarimlari buraya import etmeyi sagla` | ⏳ **BEKLEYEN GÖREV** |

---

## ⏳ Kalan Görev Detayları (Remaining Task Specifications)

### Görev #9 (Task ID: 60)
**Başlık:** *mystcrochet-app te cizip backend dbde kaydettigimiz tasarimlari buraya import etmeyi sagla*

#### 🎯 Amaç & Kapsam (Goal & Scope):
Kullanıcıların **MystCrochet App** (mobil/web uygulaması veya çizim aracı) üzerinde çizip backend veritabanında sakladığı özel motif ve proje tasarımlarını **MystCrochet Planner** içerisine aktarabilmesini (import) ve yerel veritabanına ekleyebilmesini sağlamak.

#### 🛠️ Gerekli Teknik Adımlar (Required Technical Steps):

1. **Backend API Entegrasyon Servisi (`BackendImportService`)**:
   - Backend API REST / GraphQL uç noktalarına bağlantı kuracak bir servis modülü eklenmesi.
   - Kullanıcı kimlik doğrulaması (Auth token veya kullanıcı oturumu) ile backend'deki kayıtlı tasarımların listelenmesi.

2. **Veri Modeli Dönüştürücü (Data Adapter & Mapper)**:
   - Backend'den gelen JSON tasarım şemasının (motif koordinatları, renk paletleri, ip türleri, motif şekilleri `square`, `hexagon`, `pentagon`, `triangle`) local `CrochetProject`, `ProjectSection`, ve `Motif` modellerine dönüştürülmesi.

3. **İçe Aktarma Kullanıcı Arayüzü (Import UI & Screens)**:
   - `HomeScreen` veya `EditorScreen` üzerinde "MystCrochet Backend'den İçe Aktar" butonu ve arama/listeleme diyaloğu eklenmesi.
   - Tasarımların önizlemesi gösterilerek tek tıkla yerel `StorageService` veritabanına kaydedilmesi.

4. **Görsel & Varlık Caching (Image Asset Sync)**:
   - Backend'deki fotoğraflı özel motif görsellerinin yerel depolamaya (local storage) indirilip çevrimdışı (offline) erişilebilir hale getirilmesi.

---

## 🚀 Projeyi Push Etme & Çalıştırma (Git & Forgejo)

Tüm kod değişiklikleri yerel Forgejo deposuna aktarılmıştır:
- **Forgejo Remote URL:** `https://forgejo.home/ali/mystcrochet-planner.git`
- **Ana Dal:** `main`

Test ve analiz doğrulamaları için:
```bash
flutter analyze lib/
flutter test
```
