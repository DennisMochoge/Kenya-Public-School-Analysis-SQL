# Kenya's Public School Analysis 🇰🇪📊

This project visualizes data on public schools across Kenya, using SQL for data cleaning and Power BI for interactive dashboarding. It highlights distribution by gender, region, county, and school cluster.

---

## 📂 Project Structure

- `/SQL`: Contains MySQL data cleaning scripts
- `/PowerBI`: Main `.pbix` file with interactive dashboard
- `/Screenshots`: Image preview of dashboard

---

## 🔧 Tools Used

- **MySQL** – Data storage and cleaning (via MySQL Workbench)
- **Power BI** – Dashboard creation and visual storytelling
- **Power Query (M Language)** – In-built data transformations
- **DAX** – Calculated columns and measures

---

## ⚙️ Process Overview

### 1. Data Cleanup (MySQL)

- Trimmed and standardized `SUB COUNTY` and `GENDER` fields
- Mapped erroneous sub-counties to correct values using `JOIN`
- Handled blank and malformed values
- Final clean dataset was connected to Power BI via MySQL Connector

```sql
UPDATE school_data s
JOIN sub_county_mapping m 
  ON TRIM(UPPER(s.`SUB COUNTY`)) = TRIM(UPPER(m.error_sub_county))
SET s.`SUB COUNTY` = m.correct_sub_county;

