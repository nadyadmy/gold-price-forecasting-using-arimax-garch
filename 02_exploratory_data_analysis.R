# --- 4. ANALISIS DESKRIPTIF (BAB 4.1) ---
# Fungsi untuk menampilkan statistik lengkap
deskriptif_lengkap <- function(data) {
  c("Mean" = mean(data, na.rm=T), 
    "Min" = min(data, na.rm=T), 
    "Max" = max(data, na.rm=T), 
    "Std.Dev" = sd(data, na.rm=T),
    "Skewness" = skewness(data, na.rm=T), 
    "Kurtosis" = kurtosis(data, na.rm=T))
}

cat("=== Statistik Deskriptif ===\n")
print("Harga Emas:"); print(deskriptif_lengkap(df$`Harga Pembukaan Emas`))
print("Inflasi:"); print(deskriptif_lengkap(df$Inflasi))
print("Kurs:"); print(deskriptif_lengkap(df$`Nilai Tukar Rupiah Dollar`))

