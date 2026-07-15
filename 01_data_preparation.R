# --- 1. LOAD LIBRARIES ---
library(readr)      # Membaca data
library(dplyr)      # Manipulasi data
library(stringr)    # Manipulasi string (cleaning)
library(lubridate)  # Manipulasi tanggal
library(ggplot2)    # Visualisasi data
library(forecast)   # Analisis Time Series (Arima, ndiffs)
library(tseries)    # Uji Stasioneritas (ADF)
library(TSA)        # Analisis Time Series
library(lmtest)     # Uji Signifikansi Koefisien (coeftest)
library(FinTS)      # Uji ARCH (ArchTest)
library(MASS)       # Transformasi Box-Cox
library(rugarch)    # Pemodelan GARCH
library(nortest)    # Uji Normalitas Residual
library(zoo)        # Struktur data time series
library(moments)    # Statistik Deskriptif (Skewness, Kurtosis)
library(car)        # Uji Multikolinearitas

# --- 2. DATA LOADING AND PREPARATION ---
# Membaca dataset
df <- read_csv(
  "data/raw/gold_price_2014_2025.csv",
  locale = locale(decimal_mark = ",")
)

# Data Cleaning & Formatting
# 1. Konversi Inflasi ke satuan Persen
df$Inflasi <- as.numeric(df$Inflasi) * 100 

# 2. Perbaikan Typo pada Kolom 'Bulan Tahun'
df$`Bulan Tahun` <- str_trim(df$`Bulan Tahun`)
df$`Bulan Tahun` <- str_replace_all(df$`Bulan Tahun`, "\\s+", " ")
df$`Bulan Tahun` <- str_replace_all(df$`Bulan Tahun`, "Aapril", "April")
df$`Bulan Tahun` <- str_replace_all(df$`Bulan Tahun`, "Sepptember", "September")
df$`Bulan Tahun` <- str_replace_all(df$`Bulan Tahun`, "Novemberr", "November")

# 3. Konversi ke Format Tanggal (Date)
month_mapping <- c("Januari"="January", "Februari"="February", "Maret"="March",
                   "April"="April", "Mei"="May", "Juni"="June", "Juli"="July",
                   "Agustus"="August", "September"="September", "Oktober"="October",
                   "November"="November", "Desember"="December")

df <- df %>% 
  mutate(
    Month = month_mapping[word(`Bulan Tahun`, 1)],
    Year = as.numeric(word(`Bulan Tahun`, 2)),
    Year = ifelse(Year < 100, Year + 2000, Year), # Fix tahun 2 digit
    Date = as.Date(paste(Year, Month, "01", sep = "-"), format = "%Y-%B-%d")
  ) %>% 
  filter(Year >= 2014 & Year <= 2025) %>%
  arrange(Date)

# 4. Pembagian Data (Splitting)
# Data Latih (Training): Jan 2014 - Des 2024 (132 data)
# Data Uji (Testing)   : Jan 2025 - Okt 2025 (10 data)
train_df <- df %>% filter(Date <= as.Date("2024-12-31"))
test_df  <- df %>% filter(Date >= as.Date("2025-01-01"))

# --- 3. KONVERSI KE TIME SERIES ---
emas.ts    <- ts(df$`Harga Pembukaan Emas`, start = c(2014,1), frequency = 12)
inflasi.ts <- ts(df$Inflasi, start = c(2014,1), frequency = 12)
kurs.ts    <- ts(df$`Nilai Tukar Rupiah Dollar`, start = c(2014,1), frequency = 12)

# Subset Time Series
train.emas.ts <- window(emas.ts, end=c(2024,12))
test.emas.ts  <- window(emas.ts, start=c(2025,1))

train.inflasi.ts <- window(inflasi.ts, end=c(2024,12))
test.inflasi.ts  <- window(inflasi.ts, start=c(2025,1))

train.kurs.ts <- window(kurs.ts, end=c(2024,12))
test.kurs.ts  <- window(kurs.ts, start=c(2025,1))
