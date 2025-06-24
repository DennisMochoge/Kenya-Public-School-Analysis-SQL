
# 🇰🇪 Kenya's Public School Analysis – Data Cleaning & Interactive Dashboard

This project presents an end-to-end data analytics solution showcasing public school data across Kenya. The workflow spans data cleaning with MySQL, crafting calculated DAX measures, and designing a rich, interactive dashboard with advanced drill-down capabilities.

---

## 📌 Objective

To clean, structure, and visualize school-level education data across Kenya to support decision-making by analyzing:
- Gender distribution (Boys, Girls, Mixed)
- Regional disparities (Region → County → Sub-county)
- School cluster segmentation (C1, C2, C3, C4)
- Overall school availability by location and type

---

## 🧰 Tools & Technologies

| Tool         | Purpose                                |
|--------------|----------------------------------------|
| MySQL        | Data cleaning and transformation       |
| MySQL Workbench | Writing and testing SQL scripts     |
| Power BI     | Data modeling and dashboarding         |
| Power Query (M) | Import transformations & shaping    |
| DAX          | Calculated fields and custom measures  |

---

## 🗂️ Repository Structure

```
Kenya-Public-School-Analysis/
│
├── Combined_School_Data.sql         # All data transformation queries
│
├── Kenya_School_Analysis.pbix
│
├── Dashboard.png             # Dashboard preview image
│
└── README.md
```

---

## 🛠️ Process Overview

### 1. 🔄 Data Cleaning in MySQL

- **Trim & Standardize Sub-county Names**
  ```sql
  UPDATE school_data s
  JOIN sub_county_mapping m 
    ON TRIM(UPPER(s.`SUB COUNTY`)) = TRIM(UPPER(m.error_sub_county))
  SET s.`SUB COUNTY` = m.correct_sub_county;
  ```

- **Fix Gender Values**
  Ensured that gender data matched one of: `'BOYS'`, `'GIRLS'`, `'MIXED'`.

- **Create Cluster Grouping**
  Used mappings or classification rules to segment schools into clusters (C1–C4).

- **Export Cleaned Table**
  Connected this cleaned table directly to Power BI.

---

### 2. 🔗 Data Loading in Power BI

- Connected to **MySQL database** using ODBC MySQL Connector.
- Selected only the main cleaned table (`school_data`) for modeling.
- Used Power Query to:
  - Rename columns to proper case
  - Set correct data types
  - Remove null or invalid records

---

### 3. 🧮 Data Modeling & Measures

#### a. **Hierarchies**
Created a 3-level hierarchy:
- Region → County → Sub-county

#### b. **DAX Measures**
```dax
Total Schools = COUNTROWS(school_data)

Schools by Gender = 
CALCULATE(
    COUNTROWS(school_data),
    school_data[GENDER] = "BOYS" -- repeat for GIRLS and MIXED
)

Cluster Distribution = 
CALCULATE(
    COUNTROWS(school_data),
    school_data[CLUSTER] = "C1" -- and so on for C2, C3, C4
)
```

---

## 📊 Dashboard Visuals

| Visual                | Description                                                                 |
|------------------------|-----------------------------------------------------------------------------|
| **Map**                | Shows school distribution geographically                                    |
| **Clustered Bar Chart**| No. of schools per county, broken down by gender                           |
| **Donut Chart**        | Percentage distribution of schools by gender and cluster                   |
| **Slicers**            | Filters by REGION, GENDER, CLUSTER                                         |
| **Drill-down**         | Navigate from REGION → COUNTY → SUB COUNTY                                 |


**UX Enhancements:**
- Disabled zoom-out in maps
- Ordered bars from highest to lowest
- Preserved slicer context for all visuals except cluster donut

---

## 📈 Insights Derived

- **77% of schools are mixed-gender**, highlighting inclusivity in basic education.
- **Rift Valley, Eastern, and Nyanza** regions have the highest number of schools.
- **Cluster C4 dominates** (7,200+ schools), likely indicating most common school category.
- **Nairobi lags** in school count due to urban density and alternative private systems.

---

## 📸 Dashboard Preview

![Dashboard Screenshot](/dashboard.png)

---

## 🚀 Future Enhancements

- Add filters for school types (Boarding, Day, Special Needs)

---

## 👨‍💻 Author

**Dennis Atogo Mochoge**  
Professional Banker | Data Analyst | SQL & Power BI Expert  
📧 Email: atogomochoge86@gmail.com  
🔗 [LinkedIn](https://www.linkedin.com/in/dennismochoge)  
📂 [GitHub](https://github.com/DennisMochoge)
