# --- 9. PERAMALAN / FORECASTING (BAB 4.6) ---
cat("\n=== Hasil Peramalan (Forecasting) ===\n")

# A. Point Forecast (Mean) - dari ARIMAX(0,2,1)
arimax_forecast_obj <- forecast(best_arimax, xreg = xreg.test, h = length(test.emas.ts))
forecast_mean_rp <- as.numeric(arimax_forecast_obj$mean)

# B. Volatility Forecast (Variance) - dari eGARCH
garch_forecast_obj <- ugarchforecast(best_garch_fit, n.ahead = length(test.emas.ts))
sigma_scaled <- sigma(garch_forecast_obj)
sigma_rp <- as.numeric(sigma_scaled) * scale_factor 

# C. Interval Kepercayaan Dinamis 
df_shape <- coef(best_garch_fit)["shape"]
crit_val <- qdist(distribution = "std", p = 0.975, shape = df_shape)

lower_bound <- forecast_mean_rp - (crit_val * sigma_rp)
upper_bound <- forecast_mean_rp + (crit_val * sigma_rp)

# Menampilkan Tabel Hasil Forecast Lengkap
hasil_forecast <- data.frame(
  Periode = 1:length(test.emas.ts),
  Aktual = as.numeric(test.emas.ts),
  Prediksi = forecast_mean_rp,
  Selisih = as.numeric(test.emas.ts) - forecast_mean_rp,
  Lower_95 = lower_bound,
  Upper_95 = upper_bound
)
print(hasil_forecast)