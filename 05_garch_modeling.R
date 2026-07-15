# --- 8. PEMODELAN VOLATILITAS (GARCH) - TWO STAGE SCALED (BAB 4.5) ---
# (Kode di bawah ini sama seperti sebelumnya, tidak perlu diubah)
scale_factor <- sd(sisaan.arimax)
resid_scaled <- sisaan.arimax / scale_factor

cat("\n=== Pemodelan GARCH (Two-Stage Scaled) ===\n")
fit_garch_robust <- function(data, model="sGARCH") {
  spec <- ugarchspec(
    variance.model = list(model = model, garchOrder = c(1, 1)),
    mean.model = list(armaOrder = c(0, 0), include.mean = FALSE), 
    distribution.model = "std" 
  )
  tryCatch(ugarchfit(spec = spec, data = data, solver = 'hybrid'), 
           error = function(e) return(NULL))
}

# --- A. Estimasi Semua Kandidat Model ---
cat("\n========== ESTIMASI MODEL KANDIDAT GARCH ==========\n")

# 1. Standard GARCH (sGARCH)
cat("\n--- Model 1: Standard GARCH (sGARCH) ---\n")
garch_fit <- fit_garch_robust(resid_scaled, model="sGARCH")
if(!is.null(garch_fit)) { show(garch_fit) } else { cat("Gagal Konvergensi.\n") }

# 2. Exponential GARCH (eGARCH)
cat("\n--- Model 2: Exponential GARCH (eGARCH) ---\n")
egarch_fit <- fit_garch_robust(resid_scaled, model="eGARCH")
if(!is.null(egarch_fit)) { show(egarch_fit) } else { cat("Gagal Konvergensi.\n") }

# 3. GJR-GARCH
cat("\n--- Model 3: GJR-GARCH ---\n")
gjrgarch_fit <- fit_garch_robust(resid_scaled, model="gjrGARCH")
if(!is.null(gjrgarch_fit)) { show(gjrgarch_fit) } else { cat("Gagal Konvergensi.\n") }

# --- B. Pemilihan Model Terbaik ---
cat("\n========== PERBANDINGAN AIC MODEL GARCH ==========\n")
aic_scores <- c(
  sGARCH   = if(!is.null(garch_fit)) infocriteria(garch_fit)[1] else Inf,
  eGARCH   = if(!is.null(egarch_fit)) infocriteria(egarch_fit)[1] else Inf,
  gjrGARCH = if(!is.null(gjrgarch_fit)) infocriteria(gjrgarch_fit)[1] else Inf
)
print(aic_scores)

# --- KEPUTUSAN MODEL TERBAIK ---
best_garch_fit <- egarch_fit
cat("\nModel Terpilih untuk Forecasting: eGARCH(1,1)\n")
