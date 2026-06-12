# Housing Market Analysis and Price Prediction Using SAS
Housing price analysis using SAS with data cleaning, regression modelling, and visualization.
## Project Overview
This project uses SAS to analyze housing prices and build a regression model to predict property values based on key structural and location-related features.

The workflow includes data cleaning, feature engineering, exploratory analysis, correlation study, and regression modelling.

---

## Objective
To identify the main factors influencing house prices and build a statistical model to predict sale price using SAS.

---

## Dataset Description
Two datasets were used:

- HousePrice.xlsx: Contains sale price and transaction details
- Characteristics.xlsx: Contains property features such as living area, bedrooms, bathrooms, and garage details

Both datasets were merged using a common reference ID.

---

## Methodology

### 1. Data Preparation
- Imported Excel files into SAS
- Merged datasets using `Reference`
- Cleaned missing and inconsistent values

### 2. Feature Engineering
- Created HouseAge variable
- Standardized garage information
- Removed invalid observations

### 3. Exploratory Analysis
- Frequency tables
- Summary statistics
- Distribution analysis

### 4. Correlation Analysis
- Identified relationships between price and predictors

### 5. Regression Modelling
- PROC GLM for full model with categorical variables
- PROC REG for multicollinearity checks (VIF, TOL)
- Log transformation for improved model stability

---

## Key Findings
- Living area has the strongest impact on house price
- Garage presence increases property value
- House age negatively affects price
- Log transformation improves model performance

---

## Outputs
- Graphs: `outputs/graphs`
- Tables: `outputs/tables`
- Final Report: `report/final_report.pdf`

---

## Tools Used
- SAS OnDemand for Academics
- PROC IMPORT
- PROC SGPLOT
- PROC CORR
- PROC GLM
- PROC REG

---

## Author
Hrushikesh Pandurang Dunde  
MSc Data Analytics
