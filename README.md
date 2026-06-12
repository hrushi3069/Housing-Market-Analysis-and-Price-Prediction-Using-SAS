# Housing Market Analysis and Price Prediction Using SAS

## Project Summary
This project applies SAS-based statistical modelling to analyse housing market data and identify the key drivers of property prices.

A full data pipeline was implemented, including data cleaning, feature engineering, exploratory analysis, correlation study, and regression modelling.

The final goal is to build a reliable and interpretable model for house price prediction.

---

## Business Problem
Property prices are influenced by multiple structural and temporal factors.

The objective of this project is to:
- Identify the most important factors affecting house prices
- Quantify their impact using regression analysis
- Build a statistically sound predictive model in SAS

---

## Dataset
Two datasets were used:

- HousePrice.xlsx → property sale price and transaction details  
- Characteristics.xlsx → structural property features  

Both datasets were merged using a unique reference identifier to create a unified analytical dataset.

---

## Methodology

### Data Preparation
- Imported datasets into SAS
- Merged using Reference ID
- Removed missing and inconsistent records

### Feature Engineering
- Created HouseAge variable
- Standardized garage information
- Encoded categorical variables for modelling

### Exploratory Data Analysis
- Frequency analysis for categorical variables
- Summary statistics for numerical variables
- Distribution analysis for price behaviour

### Correlation Analysis
- Measured relationships between variables
- Identified strong and weak predictors of price

### Predictive Modelling
- PROC GLM for full regression model
- PROC REG for multicollinearity diagnostics (VIF, TOL)
- Log transformation applied to improve model stability

---

## Key Insights
- Living area is the strongest predictor of house price
- Garage availability significantly increases property value
- Older properties tend to have lower prices
- Structural attributes are stronger predictors than time-based variables
- Log transformation improves model accuracy and stability

---

## Outcome
The final regression model successfully identifies the most influential property features and provides a reliable framework for predicting house prices using statistical methods in SAS.

---

## Skills Demonstrated
- Data cleaning and preprocessing
- Feature engineering
- Exploratory data analysis
- Regression modelling in SAS
- Statistical diagnostics (VIF, TOL)
- Business interpretation of data

---

## Tools Used
- SAS OnDemand for Academics
- PROC IMPORT
- PROC SGPLOT
- PROC CORR
- PROC GLM
- PROC REG

---

## Project Structure
