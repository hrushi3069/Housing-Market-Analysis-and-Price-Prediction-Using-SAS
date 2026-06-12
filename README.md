# Housing Market Analysis and Price Prediction Using SAS

## Project Overview
This project uses SAS to analyze housing data and build a regression model to predict house prices based on key property features such as living area, garage size, bathrooms, bedrooms, and house age.

The project follows a complete data analytics pipeline including data cleaning, feature engineering, exploratory data analysis, correlation analysis, and regression modelling.

---

## Business Problem
House prices depend on multiple structural features. The objective of this project is to identify the most important factors influencing house prices and build a predictive model using SAS.

---

## Dataset
Two datasets were used:

- HousePrice.xlsx → contains sale price and transaction details  
- Characteristics.xlsx → contains property features such as living area, bedrooms, bathrooms, and garage details  

Both datasets were merged using a common Reference ID.

---

## Methodology

- Data import using SAS  
- Data cleaning (missing values, duplicates, invalid records)  
- Feature engineering (HouseAge, garage classification)  
- Exploratory data analysis  
- Correlation analysis  
- Regression modelling using PROC GLM and PROC REG  
- Model validation using VIF and log transformation  

---

## Key Insights

- Living area is the strongest predictor of house price  
- Garage size and availability significantly increase property value  
- Bathrooms positively affect price  
- House age has a negative impact on price  
- Bedroom count is not significant after controlling other variables  

---

## Model Performance

- R² ≈ 0.75  
- Model is statistically significant (p < 0.0001)  
- No serious multicollinearity issues (VIF < 10)  
- Log transformation improved model stability  

---

## Project Structure

---

## Tools Used

- SAS OnDemand for Academics  
- PROC IMPORT  
- PROC SGPLOT  
- PROC CORR  
- PROC GLM  
- PROC REG  

---

## How to Run

1. Open SAS Studio (OnDemand for Academics)  
2. Upload datasets into the `data/` folder  
3. Run `sas_code/housing_analysis.sas`  
4. Check outputs in `outputs/` folder  

---

## Skills Demonstrated

- Data cleaning and preprocessing  
- Feature engineering  
- Exploratory data analysis  
- Regression modelling  
- Statistical diagnostics (VIF, TOL)  
- Business interpretation of results  

---

## Author

Hrushikesh Pandurang Dunde  
MSc Data Analytics  
