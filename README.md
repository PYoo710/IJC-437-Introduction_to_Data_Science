# IJC-437-Introduction-to-Data-Science
📌 Project Overview
This project examines whether meteorological variables alone can be used to predict the occurrence of high PM2.5 pollution events at the Sheffield Tinsley monitoring site. Rather than modelling continuous PM2.5 concentrations, the analysis focuses on a binary classification task, distinguishing between high and non-high pollution events.
Two classification approaches are implemented within a single, reproducible analysis script:
Logistic Regression as an interpretable baseline model
Random Forest to capture non-linear relationships between meteorological conditions and pollution events
This work was completed as part of the IJC437 – Introduction to Data Science module and demonstrates applied data science skills including data preprocessing, feature engineering, statistical modelling, and model evaluation.
🎯 Research Aim
To evaluate the extent to which meteorological conditions can predict high PM2.5 pollution events and to compare the performance of a statistical model with a machine-learning approach.
❓ Research Questions
How are high PM2.5 events associated with meteorological conditions such as wind speed, wind direction, and temperature?
To what extent can meteorological variables alone predict the occurrence of high PM2.5 events?
How does the predictive performance of a logistic regression model compare with that of a random forest classifier?
📊 Data Sources
PM2.5 data: Sheffield Tinsley air-quality monitoring station
Meteorological data: Wind speed, wind direction, temperature, and related variables from open meteorological datasets
All data used are secondary datasets and were cleaned and processed prior to analysis.
⚙️ Methods
The entire workflow is implemented in a single R script for clarity and reproducibility. The script follows these steps:
Data loading and preprocessing
Feature engineering and creation of a binary high PM2.5 indicator
Logistic regression modelling
Random forest modelling
Model evaluation using ROC curves, AUC, and confusion matrices
Feature importance analysis for the random forest model
🗂 Repository Structure
IJC437-PM25-Prediction/
│
├── data/        # Input datasets
├── figures/     # Generated plots and visual outputs
├── results/     # Model evaluation outputs
├── main.R       # Complete analysis pipeline
└── README.md
▶️ How to Run the Code
Requirements
R (version 4.x or later)
RStudio (recommended)
Required Packages
dplyr
lubridate
ggplot2
caret
pROC
ranger
Steps
Clone this repository:
git clone https://github.com/yourusername/IJC437-PM25-Prediction.git
Open main.R in RStudio
Install any missing packages
Run the script from top to bottom
All outputs will be saved automatically to the figures/ and results/ folders.
📈 Key Outputs
Predicted probabilities of high PM2.5 events
ROC curves and AUC scores for logistic regression and random forest models
Confusion matrices
Random forest feature importance plots
🔎 Notes on Interpretation
Results indicate associations, not causal relationships.
Model performance reflects the predictive power of meteorological variables only and does not include emissions or source data.
The use of a single script prioritises transparency and ease of reproduction over modularisation.
👤 Author
Poom Yoochareonpong
MSc Data Science
University of Sheffield
