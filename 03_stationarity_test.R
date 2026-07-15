# Plot Data Time Series
par(mfrow=c(3,1))
plot.ts(emas.ts, main="Plot Harga Emas", ylab="Rupiah")
plot.ts(inflasi.ts, main="Plot Inflasi", ylab="Persen")
plot.ts(kurs.ts, main="Plot Kurs USD/IDR", ylab="Rupiah")
par(mfrow=c(1,1))

# --- 5. UJI STASIONERITAS (BAB 4.2) ---
# 5.1 Uji Stasioneritas dalam Ragam (Box-Cox)
# Menggunakan metode manual MASS::boxcox untuk mendapatkan lambda -1.515
index <- seq(1, length(train.emas.ts))
model_lm <- lm(train.emas.ts ~ index)
# Plot Box-Cox tidak ditampilkan (plotit=FALSE)
bc <- boxcox(model_lm, lambda = seq(-2, 2, by = 0.1), plotit = FALSE)
lambda_best <- bc$x[which.max(bc$y)]
cat("Estimasi Lambda Box-Cox:", lambda_best, "\n")
# Keputusan: Lambda jauh dari 1, namun tidak dilakukan transformasi 
# demi mempertahankan karakteristik volatilitas asli (Heteroskedastisitas).

# 5.2 Uji Stasioneritas dalam Rata-rata (ADF Test)
cat("\n=== ADF Test Level (Data Asli) ===\n")
print(adf.test(train.emas.ts))
print(adf.test(train.inflasi.ts))
print(adf.test(train.kurs.ts))

cat("\n=== ADF Test First Difference ===\n")
print(adf.test(diff(train.emas.ts)))
print(adf.test(diff(train.inflasi.ts)))
print(adf.test(diff(train.kurs.ts)))

# 5.3 Validasi ndiffs (Rekomendasi d optimal)
cat("Rekomendasi d optimal (ndiffs):", ndiffs(train.emas.ts), "\n")
# Hasil ndiffs menyarankan d=2