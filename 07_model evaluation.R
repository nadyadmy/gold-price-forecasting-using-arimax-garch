# --- 10. EVALUASI AKURASI (MAPE & RMSE) ---
error_final <- hasil_forecast$Selisih
actual_values <- hasil_forecast$Aktual

MAPE_final <- mean(abs(error_final / actual_values)) * 100
RMSE_final <- sqrt(mean(error_final^2))
MAD_final  <- mean(abs(error_final))

cat("=== HASIL AKURASI FINAL ===\n")
cat("MAPE:", round(MAPE_final, 2), "%\n")
cat("RMSE:", round(RMSE_final, 2), "\n")
cat("MAD :", round(MAD_final, 2), "\n")

# --- 11. VISUALISASI HASIL PERAMALAN ---
plot_data_train <- window(train.emas.ts, start=c(2023,1))
ylim_range <- range(c(plot_data_train, upper_bound, lower_bound, test.emas.ts))

par(mfrow=c(1,1))
plot(plot_data_train, xlim = c(2023, 2026), ylim = ylim_range,
     type = "l", col = "black", lwd = 1.5, ylab = "Harga Emas (Rp)", xlab = "Periode",
     main = "Forecast ARIMAX(0,2,1)-eGARCH(1,1) (95% CI)")

abline(v=2025, col="gray", lty=3)
lines(test.emas.ts, col = "red", lwd = 2) 
lines(ts(forecast_mean_rp, start=c(2025,1), frequency=12), col = "blue", lwd = 2) 
lines(ts(upper_bound, start=c(2025,1), frequency=12), col = "darkblue", lty = 2) 
lines(ts(lower_bound, start=c(2025,1), frequency=12), col = "darkblue", lty = 2) 

legend("topleft", 
       c("Data Historis", "Data Aktual (Jan-Okt 2025)", "Prediksi ARIMAX-GARCH", "Interval Kepercayaan 95%"),
       col=c("black", "red", "blue", "darkblue"), 
       lty=c(1, 1, 1, 2), lwd=c(1.5, 2, 2, 1), cex=0.7, bg="white")
