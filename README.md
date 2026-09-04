# MystCrochet Planner 🧶

Granny Square (Hanım Dilendi Bey Beğendi) motifleri kullanarak kazak, hırka, battaniye, çanta ve serbest projeler planlamayı sağlayan modern, etkileşimli ve estetik bir Flutter web uygulaması.

---

## ✨ Özellikler

- **Hazır Proje Şablonları:**
  - 👕 **Kazak & Hırka:** Ön Gövde (20 kare), Arka Gövde (20 kare), Sol Kol (12 kare) ve Sağ Kol (12 kare) montaj şablonu.
  - 🛏️ **Battaniye & Örtü:** Bebek (5x6), Koltuk Şalı (6x8), Büyük Boy (8x10) veya özel NxM ızgara.
  - 👜 **13 Kareli Klasik Tote Çanta:** Popüler tığ işi origami katlama açılım şablonu.
  - 📐 **Özel Boyutlu Izgara:** Satır ve sütun sayısını serbestçe belirleyebileceğiniz çalışma alanı.

- **Dinamik Tur/Halka (Round-by-Round) Motif Tasarımcısı:**
  - Klasik Granny Square (3'lü trabzan öbekleri), Solid / Düz Kare ve Sunburst / Papatya modelleri.
  - Halka bazında (Tur 1 merkez, Tur 2, Tur 3, Tur 4 çerçeve) renk seçimi.
  - Zengin ve özenle seçilmiş pastel tığ işi/yün iplik paleti (Terracotta, Sage, Hardal, Keten, Gül Kurusu vb.).
  - Canlı önizleme ile anında motif oluşturma ve düzenleme.

- **Etkileşimli Tuval Araçları:**
  - 🖌️ **Fırça:** Seçili motifi tıklayarak veya sürükleyerek hücrelere yerleştirme.
  - 🔀 **Rastgele Dağıt (Shuffle):** Renklerin ve motiflerin homojen/dengeli dağılması için komşu tekrarları önleyen akıllı karıştırma algoritması.
  - 🪣 **Tümünü Doldur & Boşları Doldur.**
  - 🧹 **Silgi & Temizle.**

- **Motif Adet Sayacı & Özet:**
  - Projede toplam kaç motif olduğu, tamamlanma yüzdesi ve her bir motiften kaçar adet örülmesi gerektiğini gösteren gerçek zamanlı panel.
  - Kazak gibi çok parçalı giysilerde parça bazında döküm.

- **Kayıt & Dışa Aktarma (Export):**
  - Üyelik gerektirmeden tarayıcıda yerel saklama (`LocalStorage`).
  - Projeyi görsel şema olarak indirme (PNG çıktısı).
  - Proje dosyasını JSON olarak bilgisayara indirme ve JSON dosyasından geri yükleme (Import/Export).

- **Dil Desteği & Tasarım:**
  - Türkçe ve İngilizce çift dil desteği (tek tıkla anında geçiş).
  - Sıcak, davetkar el işi teması (keten dokusu, pastel renkler, yumuşak yuvarlak hatlar).

---

## 🚀 Çalıştırma

Geliştirme sunucusunu başlatmak için:

```bash
flutter run -d chrome
```

Web sürümünü derlemek için:

```bash
flutter build web --release
```

Testleri çalıştırmak için:

```bash
flutter test
```
