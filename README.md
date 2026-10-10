Brazilian E-Commerce Analysis (Olist)

End-to-end analysis of the Olist Brazilian e-commerce marketplace using Python (pandas), MySQL and Power BI. The project looks at revenue growth, delivery performance, customer satisfaction, payment behaviour and seller quality.

Project Overview

Olist connects small businesses across Brazil to customers through a single marketplace. This project works through about 99,000 orders placed between September 2016 and October 2018 and answers:

How fast is revenue growing month to month?
Which products sell best within each category?
Where does delivery miss the promised date?
How much do late deliveries hurt review scores?
How do payment methods and credit-card instalments relate to order value?
Which high-volume sellers are underperforming?
Dashboard Highlights

Metric	Value

Total revenue	13.59M
Total orders	99.4K
Average order value	136.68
Late delivery rate	6.57%

The dashboard also includes a monthly revenue trend, review score by days of delivery lateness, and slicers for payment type and customer status.

Tech Stack
Python: pandas, SQLAlchemy, PyMySQL (cleaning, feature engineering, loading to MySQL)
MySQL: CTEs, window functions (LAG, DENSE_RANK), joins, conditional aggregation
Power BI: KPI cards, trend charts and slicers

Workflow
Load: read the 9 Olist CSV files into pandas DataFrames.
Clean: handle missing values in order_reviews, products and orders; convert order timestamps to datetime.
Feature engineering: create late_delivery = actual delivery date minus estimated delivery date, in days (negative means early).
Load to MySQL: write the cleaned tables to the olist_db database.
Analyse: run the seven SQL queries in olist_analysis.sql.
Visualise: build the Power BI executive dashboard.

SQL Analyses
#	Analysis	Techniques
Q1	Month-over-month revenue growth	CTE, LAG()
Q2	Top 3 products per category	DENSE_RANK(), PARTITION BY
Q3	Late-delivery rate by state	Conditional SUM, CASE
Q4	Impact of late delivery on review score	JOIN, AVG, CASE grouping
Q5	Payment method impact on value and volume	GROUP BY, COUNT DISTINCT
Q6	Credit-card instalments vs average spend	Bucketing with CASE
Q7	Underperforming high-volume sellers	Multi-table JOIN, HAVING

Key Insights
Monthly revenue grew from early 2017 and levelled off near 1.0M through 2018. The drop at the end of the series reflects incomplete data for the final months.
Most orders arrive early: deliveries average about 12 days ahead of the estimate, and only 6.57% are late.
Review scores stay near 4 for orders delivered on time or early and fall steeply as delays grow.

Repository Structure
.
├── olist_anlysis.ipynb        # Cleaning, feature engineering, load to MySQL
├── olist_analysis.sql         # Seven SQL analyses
├── olist_dashboard.pbix       # Power BI dashboard
├── Olist_Project_Report.docx  # Full project report
├── images/
│   └── dashboard.png          # Dashboard screenshot
└── README.md

How to Run
Download the dataset from Kaggle: Brazilian E-Commerce Public Dataset by Olist and place the CSV files in the project folder. The data is not included in this repository because of its size.
Install dependencies:
bash
   pip install pandas sqlalchemy pymysql jupyter
Create a MySQL database named olist_db and set your credentials as environment variables rather than writing them in the notebook:
bash
   export MYSQL_USER=root
   export MYSQL_PASSWORD=your_password
Run the notebook to clean the data and load the tables into MySQL.
Run olist_analysis.sql in MySQL.
Open the Power BI file and point it at your olist_db database.

Limitations and Next Steps
Revenue is based on item price and excludes freight, while payment analyses use payment value, so the two are not directly comparable.
Review scores show association with late delivery, not proof of cause.
Planned: customer segmentation (RFM) and repeat-purchase analysis, a delivery-time prediction model, and seller and state maps using the geolocation table.

Author
Yuthika 

