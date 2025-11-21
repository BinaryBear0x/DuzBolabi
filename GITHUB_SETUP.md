# 📦 GitHub'a Private Repo Olarak Yükleme Rehberi

## 🎯 Adım Adım Talimatlar

### Adım 1: Git Repository Başlatma

Terminal'de proje klasörüne gidin ve git başlatın:

```bash
cd d:\sttapp
git init
```

### Adım 2: Dosyaları Kontrol Edin

`.gitignore` dosyası zaten hazır. Şimdi dosyaları stage'e ekleyin:

```bash
git add .
```

Durumu kontrol edin:
```bash
git status
```

### Adım 3: İlk Commit'i Yapın

```bash
git commit -m "Initial commit: Flutter gıda koruyucu uygulaması - oyunlaştırma özellikleri eklendi"
```

### Adım 4: GitHub'da Private Repository Oluşturun

1. **GitHub'a gidin:** https://github.com
2. **Giriş yapın** (hesabınız yoksa kayıt olun)
3. **Sağ üstteki "+" ikonuna** tıklayın (veya `+` > `New repository`)
4. **Repository bilgilerini doldurun:**
   - **Repository name:** `gida-koruyucu` (veya istediğiniz isim, küçük harf ve tire kullanın)
   - **Description:** "Gıda Koruyucu - STT Takip ve Oyunlaştırma Uygulaması" (opsiyonel)
   - **Visibility:** ✅ **Private** seçin (ÖNEMLİ - Public değil!)
   - **Initialize this repository with:**
     - ❌ README (işaretlemeyin - zaten kodumuz var)
     - ❌ .gitignore (işaretlemeyin - zaten var)
     - ❌ license (isteğe bağlı, boş bırakabilirsiniz)
5. **"Create repository"** butonuna tıklayın

### Adım 5: Remote Repository'yi Ekleyin

GitHub'da oluşturduğunuz repo sayfasında **yeşil "Code" butonuna** tıklayın ve **HTTPS** linkini kopyalayın.

**Örnek link formatı:**
```
https://github.com/KULLANICI-ADI/gida-koruyucu.git
```

Terminal'de remote ekleyin (KULLANICI-ADI ve REPO-ADI kısımlarını kendi bilgilerinizle değiştirin):
```bash
git remote add origin https://github.com/KULLANICI-ADI/gida-koruyucu.git
```

**Örnek:**
```bash
git remote add origin https://github.com/ozhan/gida-koruyucu.git
```

### Adım 6: Ana Branch'i `main` Olarak Ayarlayın

```bash
git branch -M main
```

### Adım 7: GitHub'a Push Edin

```bash
git push -u origin main
```

### Adım 8: Authentication (Kimlik Doğrulama)

İlk push'ta GitHub sizden kimlik doğrulama isteyebilir:

#### Seçenek A: Personal Access Token (PAT) - Önerilen

1. **GitHub'da:** 
   - Sağ üstte profil fotoğrafınız > **Settings**
   - Sol menüden **Developer settings**
   - **Personal access tokens** > **Tokens (classic)**
   - **"Generate new token"** > **"Generate new token (classic)"**

2. **Token ayarları:**
   - **Note:** "Flutter Projesi" (açıklama)
   - **Expiration:** İstediğiniz süre (90 gün, 1 yıl, vb.)
   - **Scopes:** ✅ **repo** işaretleyin (tüm repo izinleri)
   - Alt kısımdaki **"Generate token"** butonuna tıklayın

3. **Token'ı kopyalayın** (bir daha gösterilmeyecek, kaydedin!)

4. **Push yaparken:**
   - Username: GitHub kullanıcı adınız
   - Password: Token'ı yapıştırın (şifre değil!)

#### Seçenek B: GitHub CLI (Alternatif)

```bash
# GitHub CLI kuruluysa
gh auth login
git push -u origin main
```

### Adım 9: Doğrulama

1. GitHub repo sayfanızı yenileyin (F5)
2. Dosyalarınızın yüklendiğini kontrol edin
3. "Private" badge'ini görüyorsanız başarılı! ✅

---

## 🔄 Sonraki Güncellemeler İçin

Değişiklik yaptığınızda:

```bash
git add .
git commit -m "Değişiklik açıklaması"
git push
```

---

## 🛠️ Sorun Giderme

### "remote origin already exists" hatası alırsanız:
```bash
git remote remove origin
git remote add origin https://github.com/KULLANICI-ADI/REPO-ADI.git
```

### "Authentication failed" hatası:
- Personal Access Token kullanın (şifre değil!)
- Token'ın **repo** iznine sahip olduğundan emin olun
- Token'ın süresi dolmamış olmalı

### "Branch protection" hatası:
- GitHub'da repo ayarlarından branch protection'ı kontrol edin
- Varsayılan olarak `main` branch'i korunmaz, muhtemelen başka bir sorun vardır

### Büyük dosyalar için (eğer sorun olursa):
```bash
# .gitignore'u kontrol edin
# build/ klasörü ignore edilmeli
```

---

## 📝 Notlar

- **Private repo:** Sadece siz ve paylaştığınız kişiler görebilir
- **Hive adapter'ları:** `.g.dart` dosyaları commit edilmeli (kod çalışması için gerekli)
- **Test dosyaları:** `test_hive/` klasörü ignore edildi
- **Build dosyaları:** `build/` klasörü ignore edildi

---

## ✅ Kontrol Listesi

- [ ] Git kurulu (`git --version`)
- [ ] GitHub hesabı var
- [ ] Private repo oluşturuldu
- [ ] Remote eklendi
- [ ] İlk commit yapıldı
- [ ] Push başarılı
- [ ] GitHub'da dosyalar görünüyor

---

**İyi çalışmalar! 🚀**
