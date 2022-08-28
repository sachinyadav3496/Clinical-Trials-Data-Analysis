-- Hive Queries For Assignment

-- Create Table clinicaltrial_2021

CREATE TABLE IF NOT EXISTS 
clinicaltrial_2021( 
Id STRING, Sponsor STRING,
Status STRING, Start STRING,
Completion STRING, 
Type String, Submission STRING,
Conditions STRING, Interventions STRING) 
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'  
LINES TERMINATED BY '\n'  
TBLPROPERTIES("skip.header.line.count"="1");

-- Loading data in clinicaltrial_2021 table

LOAD DATA LOCAL INPATH '/home/cloudera/Desktop/clinicaltrial_2021.csv' 
INTO TABLE clinicaltrial_2021;

SELECT * FROM clinicaltrial_2021 LIMIT 5;

-- Create pharama Table 

CREATE TABLE IF NOT EXISTS pharma(
Company STRING,
Parent_Company STRING,
Penalty_Amount STRING,
Subtraction_From_Penalty STRING,
Penalty_Amount_Adjusted_For_Eliminating_Multiple_Counting STRING,
Penalty_Year STRING,
Penalty_Date STRING,
Offense_Group STRING,
Primary_Offense STRING,
Secondary_Offense STRING,
Description STRING,
Level_of_Government STRING,
Action_Type STRING,
Agency STRING,
Civil_Criminal STRING,
Prosecution_Agreement STRING,
Court STRING,
Case_ID STRING,
Private_Litigation_Case_Title STRING,
Lawsuit_Resolution STRING,
Facility_State STRING,
City STRING,
Address STRING,
Zip STRING,
NAICS_Code STRING,
NAICS_Translation STRING,
HQ_Country_of_Parent STRING,
HQ_State_of_Parent STRING,
Ownership_Structure STRING,
Parent_Company_Stock_Ticker STRING,
Major_Industry_of_Parent STRING,
Specific_Industry_of_Parent STRING,
Info_Source STRING,
Notes STRING)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde' 
WITH SERDEPROPERTIES ( "separatorChar" = ",", "quoteChar" = "\"", "escapeChar" = "\\" ) 
TBLPROPERTIES("skip.header.line.count"="1");

-- Load Data into pharama Table 

LOAD DATA LOCAL INPATH '/home/cloudera/Desktop/pharma.csv' 
INTO TABLE pharma;

SELECT * FROM pharma LIMIT 5;

-- Create mesh table 

CREATE TABLE IF NOT EXISTS mesh(
term STRING, tree STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','  
LINES TERMINATED BY '\n'  
TBLPROPERTIES("skip.header.line.count"="1");

-- Loading Data into mesh Table 

LOAD DATA LOCAL INPATH '/home/cloudera/Desktop/mesh.csv' 
INTO TABLE mesh;

SELECT * FROM mesh LIMIT 5;


-- Answer 1
-- 1. The number of studies in the dataset

SELECT COUNT(DISTINCT Id) FROM clinicaltrial_2021;

-- Answer 2
-- 2. Type of Studies

SELECT Type, COUNT(Type) as Count FROM clinicaltrial_2021
GROUP BY Type ORDER BY Count DESC;

-- Answer 3
-- 3. Top 5 Conditions

SELECT Condition, COUNT(Condition) as Count FROM (SELECT EXPLODE(SPLIT(Conditions, ","))
as Condition FROM clinicaltrial_2021) as Condition
GROUP BY Condition HAVING Condition != ""  ORDER BY Count DESC LIMIT 5;

-- Answer 4
-- 4. Most Frequent roots

SELECT tree.root, COUNT(tree.root) as Count FROM 
(SELECT EXPLODE(SPLIT(Conditions, ",")) as Condition FROM clinicaltrial_2021) as Condition
LEFT JOIN (SELECT term, SPLIT(tree, "\\.")[0] as root FROM mesh) as tree ON  
(Condition.Condition = tree.term) 
GROUP BY tree.root ORDER BY Count DESC LIMIT 10;

-- Answer 5
-- 5. Most Common sponsors that are not pharmaceutical companies,
--  with clinical trials they have sponsored

SELECT trial.Sponsor, COUNT(trial.Sponsor) as Count FROM clinicaltrial_2021 AS trial
LEFT OUTER JOIN pharma ON trial.Sponsor = pharma.Parent_Company 
GROUP BY trial.Sponsor, pharma.Parent_Company HAVING pharma.Parent_Company IS NULL 
ORDER BY Count DESC LIMIT 10;

 
-- Answer 6
-- 6. Completed Case Studies in 2021

SELECT month, COUNT(month) as count FROM (SELECT SPLIT(Completion, " ")[0] as month,
SPLIT(Completion, " ")[1] as year, Status FROM clinicaltrial_2021) as temp WHERE 
temp.year = "2021" AND Status = "Completed" GROUP BY month ORDER BY count DESC;

