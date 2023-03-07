# 1) doctor id , department and the total number of inspections attended for each doctor. 

select d.id, d.department, count(i.id) as no_of_insp_per_doc
from doctors_info as d
join inspections as i
on d.id = i.doctor_id
group by i.doctor_id;

# 2) how many inspection occurred on each day of the month 1-31. Sort by the day with most inspection.
select (select STR_TO_DATE(inspection_date,'%d/%m/%Y') ) as inspection_dates, 
count(id) as no_of_patient 
from inspections
group by inspection_dates
order by no_of_patient desc;

# 3) For each day In the inspection_date return the difference in the amount of inspection than the day before the previous date. 

create view No_of_pat_per_day 
as
select (select STR_TO_DATE(inspection_date,'%d/%m/%Y') ) as inspection_dates, 
count(id) as no_of_patient
from inspections
group by inspection_dates;

select *, lag(no_of_patient) over(order by inspection_dates) as previous_no_of_patient, 
(no_of_patient - lag(no_of_patient) over(order by inspection_dates)) as diff_in_no_of_patient
from no_of_pat_per_day;

# 4) If each inspection costs $100 normal, and $40 with insurance, insurance patients are patients with patient id devisable on 3  calculate total amount of inspection for each department.

SELECT IF(patient_id % 3 = 0, "insurance", "not_insured") as inspection_cost,
sum(CASE
	WHEN patient_id % 3 != 0 THEN 100 
    ELSE 40 end) as sum_inspection_cost
FROM inspections
group by inspection_cost;

# 5) For each doctor, display their id, full name, and the first and last inspection date they attended.

SELECT doctors_info.id, doctors_info.first_name, doctors_info.last_name,
(select STR_TO_DATE(inspection_date,'%d/%m/%Y')) as inspection_dates,
(select STR_TO_DATE(discharge_date,'%d/%m/%Y')) as discharge_date
FROM doctors_info
join inspections
on doctors_info.id = inspections.doctor_id
group by doctor_id
order by id asc;

# 6) If each inspection costs $100 normal, and $40 with insurance ,Calculate the median for the amount of inspection per each doctor. 

SELECT doctor_id,
avg(CASE
	WHEN patient_id % 3 != 0 THEN 100 
    ELSE 40 end) AS median
FROM inspections
group by doctor_id;

# 7) .  If each inspection costs $100 normal, and $40 with insurance , return all doctors that their amount of inspection falls in the first quartile as “low income” and the third quartile “high income”.

SELECT doctor_id, ntile(4)over( partition by case
	WHEN patient_id % 3 != 0 THEN 100 
    ELSE 40 end) as quartile, if(ntile(4)over( partition by case
	WHEN patient_id % 3 != 0 THEN 100 
    ELSE 40 end) >= 2, 'low income' , 'high income') as income
FROM inspections
group by doctor_id
order by doctor_id;
# 8) Return patient_id, patient full name, results from inspection. Find patients inspected multiple times for the same results. 

select  patients_info.id, first_name, last_name, inspections.results
from inspections
join patients_info on patients_info.id = inspections.patient_id
group by patients_info.id, inspections.results
having count(inspections.results) = 2;

# 9) Return the count of patients in each weight group that is 10 KG range ie. “1-10” , “11-20”, …, “131 – 140”
# 10) return count of duplicate patients based on their full name

SELECT concat(first_name, " ", last_name) as full_name , COUNT(concat(first_name, " ", last_name)) as no_of_duplicate
FROM patients_info
GROUP BY full_name
HAVING COUNT(full_name) > 1;

# 11) Return the top diseases for each allergy skip null values.

SELECT p.allergies, i.results, count(p.allergies)
from patients_info as p 
right join inspections as i on p.id = i.patient_id
group by i.results, p.allergies
having count(p.allergies) != 0 or p.allergies != null
order by count(p.allergies) desc
 ;
 
 # 12) We are looking for a specific patient that might have cancer following the criteria 
 # and return patient full name inspection results and inspection dates
 #- First_name contains an ‘c' after the first three letters.
 #- Identifies their gender as 'F'
 #- Born in April, Jun, or July
 # weight between 80kg and 90kg
 #patient_id is an odd number
 #providence 'Ontario’
 
select concat(first_name, " ", last_name) as full_name, i.results,
 STR_TO_DATE(i.inspection_date,'%d/%m/%Y') as inspection_date
 from patients_info as p join inspections as i on
 p.id = i.patient_id
 join provinces  as pv on
 p.province_id = pv.id
 where pv.province_name = 'Ontario' 
 and month(inspection_date) between 4 and 6
 and p.id % 2 = 1 and p.weight between 80 and 90
 and gender = 'F'
 and substring(p.first_name, 4, 4) = 'c'

 