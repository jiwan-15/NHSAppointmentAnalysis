# NHS GP Appointment & Data Quality Analysis (March 2024 - August 2026) (SQL)

![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-003B57?style=for-the-badge&logo=sqlite&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)

A SQL-based data validation, cleaning, and exploratory analysis project examining primary care appointment patterns, attendance rates, healthcare provider distribution, and service settings across national NHS appointment records.

The analysis was completed using **MySQL** on the `NHS_Appointment` database (`national_overview` table). It demonstrates end-to-end SQL workflows including data quality audits, schema transformations, metric calculations, and trend analysis.

---

## 📑 Table of Contents

* [📌 Project Overview](#-project-overview)
* [🛠️ Tools and Technologies](#️-tools-and-technologies)
* [📅 Dataset](#-dataset)
* [📊 Interactive Dashboard](#-interactive-dashboard)
* [🔎 Data Quality Checks](#-data-quality-checks)
* [🧹 Data Cleaning & Transformation](#-data-cleaning--transformation)
* [📈 Analysis and Key Findings](#-analysis-and-key-findings)
  * [1. Overall Summary Statistics](#1-overall-summary-statistics)
  * [2. Appointment Status & Did Not Attend (DNA) Rate](#2-appointment-status--did-not-attend-dna-rate)
  * [3. Appointment Delivery Modes](#3-appointment-delivery-modes)
  * [4. Healthcare Professional (HCP) Type Split](#4-healthcare-professional-hcp-type-split)
  * [5. Service Setting Breakdown](#5-service-setting-breakdown)
  * [6. Top National Appointment Categories](#6-top-national-appointment-categories)
  * [7. Monthly Trends & Seasonality](#7-monthly-trends--seasonality)
* [💡 Strategic Insights & Recommendations](#-strategic-insights--recommendations)
* [🧠 SQL Skills Demonstrated](#-sql-skills-demonstrated)
* [📂 Repository Structure](#-repository-structure)
* [👤 Author](#-author)

---

## 📌 Project Overview

The primary goal of this project is to evaluate over **935 million NHS primary care appointments** to understand operational delivery, attendance outcomes, modality distribution, and workforce utilization.

The analysis covers:
* Pre-cleaning data quality validation (nulls, duplicates, invalid date formats, whitespace)
* Schema modernization and date datatype conversion
* Attendance vs. Did Not Attend (DNA) rate calculations
* Delivery mode distributions (Face-to-Face vs. Telehealth vs. Home Visits)
* Workforce distribution (GP vs. Other Practice Staff)
* Service setting and appointment category profiling
* Temporal monthly volume trends

---

## 🛠️ Tools and Technologies

* **SQL**
* **MySQL**
* **MySQL Workbench**
* **Tableau / Interactive Visualization**
* **GitHub**

---

## 📅 Dataset

* **Database:** `NHS_Appointment`
* **Raw Table:** `national_overview`
* **Cleaned Table:** `national_overview_clean`
* **Dataset Source:** Sourced from **NHS England (Appointments in General Practice)**.
* **Credit:** Data provided under the Open Government Licence v3.0.
* **Dataset Scope:** 30 unique appointment months across national NHS primary care services (March 2024 – August 2026).

The raw table structure consists of the following fields:

| Column | Description | Data Type |
| :--- | :--- | :--- |
| `APPOINTMENT_MONTH` | Reporting month and year (e.g., APR2024) | `VARCHAR` |
| `APPT_STATUS` | Status of appointment (`Attended`, `DNA`, `Unknown`) | `VARCHAR` |
| `HCP_TYPE` | Type of healthcare professional (`GP`, `Other Practice staff`, `Unknown`) | `VARCHAR` |
| `APPT_MODE` | Delivery mode (`Face-to-Face`, `Telephone`, `Video Conference/Online`, etc.) | `VARCHAR` |
| `SERVICE_SETTING` | Operational setting (`General Practice`, `PCN`, etc.) | `VARCHAR` |
| `CONTEXT_TYPE` | Mapping classification | `VARCHAR` |
| `NATIONAL_CATEGORY` | Granular appointment reason classification | `VARCHAR` |
| `APPOINTMENTS` | Total count of aggregate appointments | `VARCHAR` / `NUMERIC` |

---

## 📊 Interactive Dashboard

Explore the interactive dashboard summarizing key national appointment metrics, trends, and clinical delivery breakdowns.

👉 **[View Interactive Dashboard Artifact](https://claude.ai/artifact/T7oNY7tkwqMbUMeU4cgGh1)**  
👉 **[View Interactive Dashboard Preview Image](nhs_appointments_dashboard.png)**

*(Note: Dashboard visualizations developed with AI assistance).*

---

## 🔎 Data Quality Checks

Before conducting strategic analysis, comprehensive SQL data quality checks were run on the raw `national_overview` table.

| Check Type | Query Goal | Result | Status |
| :--- | :--- | :---: | :---: |
| **Total Rows** | Count all records in raw table | 53,634 | ✅ Verified |
| **Missing Values** | Check for `NULL` or empty strings across all 8 columns | 0 missing | ✅ Clean |
| **Duplicate Records** | Group by all attributes to find exact row duplicates | 0 duplicates | ✅ Clean |
| **Negative/Zero Volumes** | Filter for invalid `APPOINTMENTS <= 0` | 0 records | ✅ Valid |
| **Date Pattern Match** | `REGEXP` validation against `^(JAN\|FEB\|...)[0-9]{4}$` | 0 invalid | ✅ Valid |
| **Trailing Whitespace** | Compare columns against `TRIM()` output | 0 padded | ✅ Clean |

> **Data Type Bug Identified:** The `STR_TO_DATE()` function initially returned `NULL` on `APPOINTMENT_MONTH` because the date was stored as string text (e.g., `APR2024`) without day values, requiring schema transformation.

---

## 🧹 Data Cleaning & Transformation

A production-ready cleaned table `national_overview_clean` was generated using SQL:

```sql
CREATE TABLE national_overview_clean AS
SELECT DISTINCT
    STR_TO_DATE(
        CONCAT('01', UPPER(TRIM(APPOINTMENT_MONTH))),
        '%d%b%Y'
    ) AS APPOINTMENT_MONTH,
    TRIM(APPT_STATUS) AS APPT_STATUS,
    TRIM(HCP_TYPE) AS HCP_TYPE,
    TRIM(APPT_MODE) AS APPT_MODE,
    TRIM(SERVICE_SETTING) AS SERVICE_SETTING,
    TRIM(CONTEXT_TYPE) AS CONTEXT_TYPE,
    TRIM(NATIONAL_CATEGORY) AS NATIONAL_CATEGORY,
    CAST(APPOINTMENTS AS UNSIGNED) AS APPOINTMENTS
FROM national_overview
WHERE UPPER(TRIM(APPOINTMENT_MONTH)) REGEXP '^(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)[0-9]{4}$'
  AND APPOINTMENTS >= 0;
```

---

## 📈 Analysis and Key Findings

### 1. Overall Summary Statistics

```sql
SELECT
    COUNT(*) AS Total_Records,
    SUM(APPOINTMENTS) AS Total_Appointments,
    ROUND(AVG(APPOINTMENTS), 2) AS Total_Average,
    MIN(APPOINTMENTS) AS Minimum_Appointments,
    MAX(APPOINTMENTS) AS Maximum_Appointments
FROM national_overview_clean;
```

| Metric | Value |
| :--- | :--- |
| **Total Records** | 53,634 |
| **Total NHS Appointments** | 935,001,148 |
| **Average Appointments / Record** | 17,432.99 |
| **Min Record Volume** | 1 |
| **Max Record Volume** | 4,563,931 |

* **Key Finding:** NHS primary care recorded over **935 million total appointments** over the 30-month period evaluated.

---

### 2. Appointment Status & Did Not Attend (DNA) Rate

```sql
SELECT
    SUM(CASE WHEN APPT_STATUS = 'Attended' THEN APPOINTMENTS ELSE 0 END) AS Attended,
    SUM(CASE WHEN APPT_STATUS = 'DNA' THEN APPOINTMENTS ELSE 0 END) AS DNA,
    CONCAT(
        ROUND(
            SUM(CASE WHEN APPT_STATUS = 'DNA' THEN APPOINTMENTS ELSE 0 END) * 100.0 /
            NULLIF(SUM(CASE WHEN APPT_STATUS IN ('Attended', 'DNA') THEN APPOINTMENTS ELSE 0 END), 0),
            2
        ), '%'
    ) AS DNA_Rate
FROM national_overview_clean;
```

| Status Outcome | Total Appointments | Percentage Share |
| :--- | :--- | :--- |
| **Attended** | 837,786,699 | 89.60% |
| **Unknown** | 57,041,825 | 6.10% |
| **Did Not Attend (DNA)** | 40,172,624 | 4.30% |
| **Total** | **935,001,148** | **100.00%** |

* **DNA Rate (Known Outcomes Only):** Excluding `Unknown` outcomes yields an adjusted **4.58% DNA rate** across 877,959,323 known outcomes (representing **40.17 million missed appointments**).

---

### 3. Appointment Delivery Modes

```sql
SELECT
    APPT_MODE,
    SUM(APPOINTMENTS) AS Total_Appointments,
    CONCAT(
        ROUND(
            SUM(APPOINTMENTS) * 100.0 / (SELECT SUM(APPOINTMENTS) FROM national_overview_clean),
            2
        ), '%'
    ) AS Percentage
FROM national_overview_clean
GROUP BY APPT_MODE
ORDER BY Total_Appointments DESC;
```

| Delivery Mode | Total Appointments | Share (%) |
| :--- | :--- | :--- |
| **Face-to-Face** | 590,667,947 | 63.17% |
| **Telephone** | 231,709,215 | 24.78% |
| **Video Conference / Online** | 76,304,683 | 8.16% |
| **Unknown** | 25,279,266 | 2.70% |
| **Home Visit** | 11,040,037 | 1.18% |

* **Key Finding:** Face-to-face encounters remain the primary mode of care (**63.17%**), while combined virtual modalities (telephone, video, online) represent **32.94%** of delivery.

---

### 4. Healthcare Professional (HCP) Type Split

```sql
SELECT
    HCP_TYPE,
    SUM(APPOINTMENTS) AS Total_Appointments,
    CONCAT(
        ROUND(
            SUM(APPOINTMENTS) * 100.0 / (SELECT SUM(APPOINTMENTS) FROM national_overview_clean),
            2
        ), '%'
    ) AS Percentage
FROM national_overview_clean
GROUP BY HCP_TYPE
ORDER BY Total_Appointments DESC;
```

| HCP Type | Total Appointments | Share (%) |
| :--- | :--- | :--- |
| **Other Practice Staff** | 494,759,428 | 52.92% |
| **GP** | 417,249,114 | 44.63% |
| **Unknown** | 22,992,606 | 2.46% |

* **Key Finding:** Non-GP practice staff (e.g., nurses, pharmacists, healthcare assistants) delivered **52.92%** of all primary care appointments, highlighting the shift toward multidisciplinary care teams.

---

### 5. Service Setting Breakdown

```sql
SELECT
    SERVICE_SETTING,
    SUM(APPOINTMENTS) AS Total_Appointments,
    CONCAT(
        ROUND(
            SUM(APPOINTMENTS) * 100.0 / (SELECT SUM(APPOINTMENTS) FROM national_overview_clean),
            2
        ), '%'
    ) AS Percentage
FROM national_overview_clean
GROUP BY SERVICE_SETTING
ORDER BY Total_Appointments DESC;
```

| Service Setting | Total Appointments | Share (%) |
| :--- | :--- | :--- |
| **General Practice** | 846,911,413 | 90.58% |
| **Primary Care Network (PCN)** | 49,298,149 | 5.27% |
| **Unmapped** | 16,485,625 | 1.76% |
| **Other** | 11,329,011 | 1.21% |
| **Extended Access Provision** | 10,976,950 | 1.17% |

---

### 6. Top National Appointment Categories

```sql
SELECT
    NATIONAL_CATEGORY,
    SUM(APPOINTMENTS) AS Total_Appointments,
    CONCAT(
        ROUND(
            SUM(APPOINTMENTS) * 100.0 / (SELECT SUM(APPOINTMENTS) FROM national_overview_clean),
            2
        ), '%'
    ) AS Percentage
FROM national_overview_clean
GROUP BY NATIONAL_CATEGORY
ORDER BY Total_Appointments DESC
LIMIT 10;
```

| National Category | Total Appointments | Share (%) |
| :--- | :--- | :--- |
| **General Consultation Routine** | 248,298,491 | 26.56% |
| **General Consultation Acute** | 180,427,304 | 19.30% |
| **Planned Clinics** | 140,021,485 | 14.98% |
| **Planned Clinical Procedure** | 99,766,160 | 10.67% |
| **Inconsistent Mapping** | 99,013,612 | 10.59% |
| **Clinical Triage** | 97,985,128 | 10.48% |
| **Unmapped** | 16,485,625 | 1.76% |
| **Structured Medication Review** | 8,938,218 | 0.96% |
| **Care Related Encounter (Other)** | 8,437,947 | 0.90% |
| **Unplanned Clinical Activity** | 8,397,834 | 0.90% |

* **Key Data Quality Finding:** Routine and acute general consultations account for **45.86%** of appointment activity. Inconsistent mapping and unmapped entries account for **12.35% (\~115.5M appointments)**, indicating key targets for data standardisation.

---

### 7. Monthly Trends & Seasonality

```sql
SELECT
    DATE_FORMAT(APPOINTMENT_MONTH, '%Y-%m') AS Month,
    SUM(APPOINTMENTS) AS Total_Appointments
FROM national_overview_clean
GROUP BY APPOINTMENT_MONTH
ORDER BY APPOINTMENT_MONTH;
```

* **Peak Demand Month:** October 2025 (**39,332,896 appointments**)
* **Lowest Demand Month:** August 2025 (**27,188,966 appointments**)
* **Monthly Variance:** **12.14 million appointments** differential between peak autumn demand and summer troughs.

---

## 💡 Strategic Insights & Recommendations

1. **Attendance Management:** Automated SMS reminders and simplified digital cancellation channels could significantly reduce the **4.58% DNA rate (~40.17M missed appointments)**.
2. **Workforce Optimization:** Non-GP staff managing **52.92%** of consultations confirms the success of multidisciplinary care models; continued resource investment in PCN staff roles is recommended.
3. **Data Quality Governance:** Standardizing clinical recording rules can eliminate the **12.35%** unmapped or inconsistently categorized volume.
4. **Capacity & Seasonal Planning:** Resource planning should account for the recurring **~12.1 million monthly appointment variance** between summer low points and autumn spikes.

---

## 🧠 SQL Skills Demonstrated

* **Data Cleaning & ETL:** `CREATE TABLE AS SELECT`, `TRIM()`, `UPPER()`, `CAST()`, `REGEXP` filtering
* **Date Parsing & Formatting:** `STR_TO_DATE()`, `CONCAT()`, `DATE_FORMAT()`
* **Aggregations & Grouping:** `COUNT()`, `SUM()`, `AVG()`, `MIN()`, `MAX()`, `GROUP BY`, `ORDER BY`, `LIMIT`
* **Advanced Metrics:** Conditional aggregation with `CASE WHEN`, ratio/percentage formulas, safe division handling via `NULLIF()`

---

## 📂 Repository Structure

```text
├── README.md                      <- Project summary and documentation
├── nhs_appointments_analysis.sql   <- SQL queries (cleaning, checks, analysis)
└── nhs_appointments_dashboard.png  <- Interactive dashboard preview image
```

---

## 👤 Author

**Jiwan Gurung**
* **LinkedIn:** [Jiwan Gurung](https://www.linkedin.com/in/jiwan-gurung-792088124/)
