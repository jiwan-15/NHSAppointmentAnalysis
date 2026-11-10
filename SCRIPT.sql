use NHS_Appointment;


-- BASIC DATA INFO

-- Dataset overview
select *
from national_overview

-- total records
select
	  count(*) as total_rows
from national_overview;   

-- Answer: Total records 53634.

-- Column names and data types
describe national_overview;

-- Unique values
select 
      count(distinct APPOINTMENT_MONTH) as unique_months,
      count(distinct APPT_STATUS) as unique_status,
      count(distinct HCP_TYPE) as unique_HCP,
      count(distinct APPT_MODE) as unique_mode,
      count(distinct SERVICE_SETTING) as unique_setting,
      count(distinct CONTEXT_TYPE) as unique_context,
      count(distinct NATIONAL_CATEGORY) as unique_category
from national_overview;

-- Answer: The dataset contains 30 unique appointment months, 3 appointment statuses, 3 HCP types, 5 appointment modes, 5 service settings, 3 context types, and 19 national categories.

-- Unique categories
select distinct APPT_STATUS
from national_overview;

-- Answer: 'Attended','DNA','Unknown'

select distinct HCP_TYPE
from national_overview;

-- Answer: 'GP','Other Practice staff','Unknown'

select distinct APPT_MODE
from national_overview;

-- Answer: 'Face-to-Face','Home Visit','Telephone','Unknown','Video Conference/Online'


select distinct SERVICE_SETTING
from national_overview;

-- Answer: 'Extended Access Provision','General Practice','Other','Primary Care Network','Unmapped'


select distinct CONTEXT_TYPE
from national_overview;

-- Answer: 'Care Related Encounter','Inconsistent Mapping','Unmapped'


select distinct NATIONAL_CATEGORY
from national_overview;

-- Answer: 'Care Home Needs Assessment & Personalised Care and Support Planning'
'Care Home Visit'
'Care Related Encounter but does not fit into any other category'
'Clinical Triage'
'General Consultation Acute'
'General Consultation Routine'
'Group Consultation and Group Education'
'Home Visit'
'Non-contractual chargeable work'
'Patient contact during Care Home Round'
'Planned Clinical Procedure'
'Planned Clinics'
'Service provided by organisation external to the practice'
'Social Prescribing Service'
'Structured Medication Review'
'Unplanned Clinical Activity'
'Walk-in'
'Inconsistent Mapping'
'Unmapped'

-- Dataset date range
select
      min(str_to_date(APPOINTMENT_MONTH, '%b%Y')) as First_Month,
      max(str_to_date(APPOINTMENT_MONTH, '%b%Y')) as Last_Month
from national_overview;

-- Answer: NULL, NULL (APPOINTMENT_MONTH data types needs to be cleaned to correct data type). 

-- DATA CLEANING (if the dataset needs cleaning).

-- Missing values
select
      sum(APPOINTMENT_MONTH is null or trim(APPOINTMENT_MONTH) = '') as Missing_Month,
      sum(APPT_STATUS is null or trim(APPT_STATUS) = '') as Missing_Status,
      sum(HCP_TYPE is null or trim(HCP_TYPE) = '') as Missing_HCP,
      sum(APPT_MODE is null or trim(APPT_MODE) = '') as Missing_Mode,
      sum(SERVICE_SETTING is null or trim(SERVICE_SETTING) = '') as Missing_Service,
      sum(CONTEXT_TYPE is null or trim(CONTEXT_TYPE) = '') as Missing_Context,
      sum(NATIONAL_CATEGORY is null or trim(NATIONAL_CATEGORY) = '') as Missing_Category,
      sum(APPOINTMENTS is null or trim(APPOINTMENTS) = '') as Missing_Appointments
from national_overview;

-- Answer: 0 (All eight columns have zero missing values).

-- Duplicate records
select
	 count(*) as total_duplicates
from(
     select *
     from national_overview
     
     group by
             APPOINTMENT_MONTH,
             APPT_STATUS,
             HCP_TYPE,
             APPT_MODE,
             SERVICE_SETTING,
             CONTEXT_TYPE,
             NATIONAL_CATEGORY,
             APPOINTMENTS
       having count(*) >1
) as duplicates;

-- Answer: 0 duplicates. 

-- Appointments values
select *
from national_overview
where APPOINTMENTS <0
or APPOINTMENTS = 0;
 
-- Answer: Appointments values are correct (No records returned). 

-- Invalid date formats (month column currently uses values such as APR2024). 
select *
from national_overview
where upper(trim(APPOINTMENT_MONTH)) not REGEXP
'^(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)[0-9]{4}$';

-- Answer: No invalid month records.

-- Checking unwanted spaces
select *
from national_overview
where APPT_STATUS <> trim(APPT_STATUS)
or HCP_TYPE <> trim(HCP_TYPE)
or APPT_MODE <> trim(APPT_MODE)
or SERVICE_SETTING <> trim(SERVICE_SETTING)
or CONTEXT_TYPE <> trim(CONTEXT_TYPE)
or NATIONAL_CATEGORY <> trim(NATIONAL_CATEGORY);

-- Answer: No unwanted leading or trailing spaces.


-- CREATING A CLEANED DATASET (converting APPOINTMENT_MONTH from VARCHAR into DATE and ensuring APPOINTMENTS is stored as a numeric value).
CREATE TABLE national_overview_clean AS

select distinct

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

WHERE UPPER(TRIM(APPOINTMENT_MONTH)) REGEXP
'^(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)[0-9]{4}$'

AND APPOINTMENTS >= 0;


-- ALTER TABLE national_overview_clean
SELECT *
FROM national_overview_clean
WHERE APPOINTMENT_MONTH IS NULL
   OR APPOINTMENTS IS NULL;
   
-- Cleand dataset overview
select *
from national_overview_clean

-- Columns name and data types
describe national_overview_clean

-- FINAL DATA QUALITY VALIDATION
select
      count(*) as total_rows,
      sum(APPOINTMENT_MONTH is null) as Missing_Date,
      sum(APPT_STATUS is null) as Missing_Status,
      sum(HCP_TYPE is null) as Missing_HCP,
      sum(APPT_MODE is null) as Missing_Appointment,
      sum(SERVICE_SETTING is null) as Missing_Service,
      sum(APPOINTMENTS <0) as Negative_Values,
      sum(APPOINTMENTS =0) as Zero_Values
from national_overview_clean;

-- Answer: '53634','0','0','0','0','0','0','0'


-- ANALYSIS

-- Total appointments and basic statistics
select 
	  count(*) as Total_Records,
      sum(APPOINTMENTS) as Total_Appointments,
      round(avg(APPOINTMENTS), 2) as Total_Average,
      min(APPOINTMENTS) as Minimum_Appointments,
      max(APPOINTMENTS) as Maximum_Appointments
from national_overview_clean;

-- Answer: Total Records '53634',Total appointments '935001148', Total average '17432.99',Minimum appointments'1',Maximum appointments'4563931'

-- Appointment status analysis
select
      APPT_STATUS,
      sum(APPOINTMENTS) as Total_Appointments,
      concat(
            round(
				  sum(APPOINTMENTS) * 100.0/
                  (select sum(APPOINTMENTS) 
				  from national_overview_clean),
             2),
           '%'  
	   )	as Percentage
 from national_overview_clean
 group by APPT_STATUS
 order by Total_Appointments;
 
 -- Answer: 'DNA','40172624','4.30%'
'Unknown','57041825','6.10%'
'Attended','837786699','89.60%'

-- DNA (Did Not Attend) analysis
SELECT
    SUM(
        CASE
            WHEN APPT_STATUS = 'Attended'
            THEN APPOINTMENTS
            ELSE 0
        END
    ) AS Attended,

    SUM(
        CASE
            WHEN APPT_STATUS = 'DNA'
            THEN APPOINTMENTS
            ELSE 0
        END
    ) AS DNA,

    CONCAT(
        ROUND(
            SUM(
                CASE
                    WHEN APPT_STATUS = 'DNA'
                    THEN APPOINTMENTS
                    ELSE 0
                END
            ) * 100.0 /
            NULLIF(
                SUM(
                    CASE
                        WHEN APPT_STATUS IN ('Attended', 'DNA')
                        THEN APPOINTMENTS
                        ELSE 0
                    END
                ),
                0
            ),
            2
        ),
        '%'
    ) AS DNA_Rate
FROM national_overview_clean;

-- Answer: attended '837786699', DNA '40172624', DNA_Rate '4.58%'
-- NOTE: Approximately 4.58% of appointments with a known outcome were recorded as DNA. Unknown outcomes are excluded from this calculation.

-- Appointment mode analysis
select
      APPT_MODE,
      sum(APPOINTMENTS) as Total_Appointments,
      
      concat( 
             round(
				   sum(APPOINTMENTS) * 100.0/
                   (select sum(APPOINTMENTS)
                   from national_overview_clean), 
				2), 
			'%'
		) as Percentage 
from national_overview_clean
group by APPT_MODE
order by Total_Appointments;
       
-- Answer: 'Home Visit','11040037','1.18%'
'Unknown','25279266','2.70%'
'Video Conference/Online','76304683','8.16%'
'Telephone','231709215','24.78%'
'Face-to-Face','590667947','63.17%'

-- Healthcare professional (HCP) analysis
select
      HCP_TYPE,
      sum(APPOINTMENTS) as Total_Appointments
from national_overview_clean
group by HCP_TYPE
order by Total_Appointments desc;      

-- Answer: 'Other Practice staff','494759428'
'GP','417249114'
'Unknown','22992606'

-- NOTE: Finding: Other practice staff account for a larger appointment volume than GPs.

-- Service setting analysis
select
	  SERVICE_SETTING,
      sum(APPOINTMENTS) as Total_Appointments,
      
      concat(
             round(
                   sum(APPOINTMENTS) * 100.0/
                   (select sum(APPOINTMENTS)
                   from national_overview_clean),
                   2),
				'%'
             ) as Percentage      
from national_overview_clean
group by SERVICE_SETTING
order by Total_Appointments desc;      

-- Answer: 'General Practice','846911413','90.58%'
'Primary Care Network','49298149','5.27%'
'Unmapped','16485625','1.76%'
'Other','11329011','1.21%'
'Extended Access Provision','10976950','1.17%'

-- National appointment category analysis
select
      NATIONAL_CATEGORY,
      sum(APPOINTMENTS) as Total_Appointments,
      
      concat(
             round(sum(APPOINTMENTS) * 100.0/
             (select sum(APPOINTMENTS)
             from national_overview_clean),
			2),
		'%'
	) as Percentage
from national_overview_clean
group by NATIONAL_CATEGORY
order by Total_Appointments desc
limit 10;    

-- Answer: 'General Consultation Routine','248298491','26.56%'
'General Consultation Acute','180427304','19.30%'
'Planned Clinics','140021485','14.98%'
'Planned Clinical Procedure','99766160','10.67%'
'Inconsistent Mapping','99013612','10.59%'
'Clinical Triage','97985128','10.48%'
'Unmapped','16485625','1.76%'
'Structured Medication Review','8938218','0.96%'
'Care Related Encounter but does not fit into any other category','8437947','0.90%'
'Unplanned Clinical Activity','8397834','0.90%'

-- NOTE: Routine and acute general consultations represent the two largest identifiable appointment categories.

-- Monthly appointment trends
select 
      date_format(APPOINTMENT_MONTH, '%Y-%m') as month,
      sum(APPOINTMENTS) as Total_Appointments
from national_overview_clean
group by APPOINTMENT_MONTH
order by APPOINTMENT_MONTH;

-- Answer: Appointment volumes peaked in October 2025, with 39.33 million appointments, and reached their lowest point in August 2025, with 27.19 million appointments.