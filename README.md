# IJC-437-Introduction-to-Data-Science
## Project Overview
This project investigates whether **meteorological variables alone** can be used to predict the occurrence of **high PM2.5 pollution events** at the Sheffield Tinsley monitoring site.  
Instead of modelling continuous PM2.5 concentration levels, the analysis focuses on a **binary classification task**, identifying whether a high PM2.5 event occurs or not.

Two modelling approaches are implemented within a single, reproducible analysis script:
- Logistic Regression (baseline, interpretable model)
- Random Forest (non-linear machine learning model)

This project was completed as part of the **IJC437 – Introduction to Data Science** module.

---

## Research Aim
To evaluate the predictive power of meteorological conditions for identifying high PM2.5 pollution events and to compare the performance of a statistical model with a machine learning approach.

---

## Research Questions
1. How are high PM2.5 events associated with meteorological conditions such as wind speed, wind direction, and temperature?  
2. To what extent can meteorological variables alone predict the occurrence of high PM2.5 events?  
3. How does the predictive performance of logistic regression compare with that of a random forest classifier?

---

## Data Sources
- **PM2.5 concentration data**: Sheffield Tinsley air-quality monitoring station  
- **Meteorological data**: Wind speed, wind direction, temperature, and related variables from open meteorological datasets  

All data used in this project are secondary datasets and were cleaned and processed prior to analysis.

---

## Methods
The complete data-science workflow is implemented in a **single R script (`main.R`)**, following these steps:

1. Data loading and preprocessing  
2. Feature engineering and creation of a binary high PM2.5 indicator  
3. Logistic regression modelling  
4. Random forest modelling  
5. Model evaluation using ROC curves, AUC, and confusion matrices  
6. Feature importance analysis for the random forest model  

---

## Repository Structure
IJC437-PM25-Prediction/
│
├── data/ # Input datasets
├── figures/ # Generated plots and visual outputs
├── results/ # Model evaluation outputs
├── main.R # Complete analysis pipeline
└── README.md

---

## How to Run the Code

### Requirements
- R (version 4.0 or later)
- RStudio (recommended)

### Required Packages
The following R packages are used in this project:
```r
dplyr
lubridate
ggplot2
caret
pROC
ranger
```r
##Steps
Clone this repository:
git clone https://github.com/yourusername/IJC437-PM25-Prediction.git
Open the project in RStudio
Install any missing packages
Open main.R and run the script from top to bottom
All outputs will be saved to the figures/ and results/ folders.
Key Outputs
Predicted probabilities of high PM2.5 events
ROC curves and AUC scores for logistic regression and random forest models
Confusion matrices
Random forest feature importance plots
##Notes on Interpretation
The results describe associations, not causal relationships.
Only meteorological variables are used; emission source data are not included.
The use of a single script prioritises transparency and ease of reproduction.
##Author
Poom Yoochareonpong
MSc Data Science
University of Sheffield

