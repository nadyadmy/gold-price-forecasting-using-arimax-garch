# --- 6. PEMBENTUKAN DAN PEMILIHAN MODEL ARIMAX (BAB 4.3) ---
# 6.1 Analisis Korelasi
cat("\n=== Analisis Korelasi ===\n")
cor_emas_inflasi <- cor(train_df$`Harga Pembukaan Emas`, train_df$Inflasi)
cor_emas_kurs <- cor(train_df$`Harga Pembukaan Emas`, train_df$`Nilai Tukar Rupiah Dollar`)
cat("Korelasi Emas vs Inflasi:", cor_emas_inflasi, "\n")
cat("Korelasi Emas vs Kurs   :", cor_emas_kurs, "\n")

# 6.2 Uji Multikolinearitas
r <- cor(train_df$Inflasi, train_df$`Nilai Tukar Rupiah Dollar`)
vif_manual <- 1 / (1 - r^2)
cat("Nilai VIF Manual:", vif_manual, "\n")

# 6.3 Estimasi Model Kandidat (Sub-bab Pemilihan Model)
# Matriks Variabel Eksogen
xreg.train <- cbind(Inflasi = train_df$Inflasi, Kurs = train_df$`Nilai Tukar Rupiah Dollar`)
xreg.test  <- cbind(Inflasi = test_df$Inflasi, Kurs = test_df$`Nilai Tukar Rupiah Dollar`)

# --- MODEL A: ARIMAX(1,1,1) ---
cat("\n=== ESTIMASI MODEL A: ARIMAX(1,1,1) ===\n")
model_d1 <- Arima(train.emas.ts, order = c(1,1,1), xreg = xreg.train, method = "ML")
summary(model_d1)
coeftest(model_d1)

# --- MODEL B: ARIMAX(0,2,1) ---
cat("\n=== ESTIMASI MODEL B: ARIMAX(0,2,1) ===\n")
model_d2 <- Arima(train.emas.ts, order = c(0,2,1), xreg = xreg.train, method = "ML")
summary(model_d2)
coeftest(model_d2)

# 6.4 Tabel Perbandingan Model (Untuk Justifikasi di Skripsi)
cat("\n=== TABEL PERBANDINGAN MODEL ===\n")
# Mengambil nilai AIC, RMSE, dan P-value Ljung-Box
aic_d1 <- model_d1$aic
aic_d2 <- model_d2$aic

rmse_d1 <- accuracy(model_d1)[2] # Mengambil RMSE Training
rmse_d2 <- accuracy(model_d2)[2]

lb_d1 <- Box.test(residuals(model_d1), lag=24, type="Ljung-Box")$p.value
lb_d2 <- Box.test(residuals(model_d2), lag=24, type="Ljung-Box")$p.value

perbandingan <- data.frame(
  Model = c("ARIMAX(1,1,1)", "ARIMAX(0,2,1)"),
  AIC = c(aic_d1, aic_d2),
  RMSE = c(rmse_d1, rmse_d2),
  LjungBox_Pval = c(lb_d1, lb_d2),
  Keterangan = c(ifelse(aic_d1 < aic_d2, "Terbaik", ""), ifelse(aic_d2 < aic_d1, "Terbaik", ""))
)
print(perbandingan)

# --- KEPUTUSAN FINAL MEAN MODEL ---
# Kita set ARIMAX(0,2,1) sebagai best model untuk lanjut ke tahap GARCH
best_arimax <- model_d2 
cat("\nModel yang dipilih untuk tahap selanjutnya: ARIMAX(0,2,1)\n")


# --- 7. UJI DIAGNOSTIK MEAN MODEL TERPILIH (BAB 4.3.6 & 4.4) ---
sisaan.arimax <- residuals(best_arimax)

# Uji White Noise (Ljung-Box)
cat("\n=== Uji White Noise Model Terpilih (Ljung-Box) ===\n")
print(Box.test(sisaan.arimax, lag = 24, type = "Ljung-Box"))

# Uji Normalitas (Kolmogorov-Smirnov)
cat("\n=== Uji Normalitas Residual ===\n")
print(ks.test(sisaan.arimax, "pnorm", mean=mean(sisaan.arimax), sd=sd(sisaan.arimax)))

# Uji Heteroskedastisitas (ARCH Test - Bab 4.4)
cat("\n=== Uji Efek ARCH (Heteroskedastisitas) ===\n")
# Jika p-value < 0.05, maka lanjut ke GARCH
print(ArchTest(sisaan.arimax))