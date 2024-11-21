-- This dataset relates to loan application and risk assesment
-- Display the whole data 
SELECT * FROM loan_approval.`loan dataset`;

-- firstly we have to get the column names and its datatypes.
-- By knowing the datatypes of each column we can analyse the dataset
-- for this we use show or describe keywords to get the datatypes of each column in mysql

-- Display the datatype of each column
show columns from `loan dataset`;
describe  `loan dataset`;
-- convertng the applictaiondate column datatype into suitable format i.e date format for our analysis
SELECT STR_TO_DATE(ApplicationDate, '%m/%d/%Y') AS ConvertedDate
FROM `loan dataset`;
set safe_sql_updates = 0 ;
UPDATE `loan dataset`
SET ApplicationDate = STR_TO_DATE(ApplicationDate, '%m/%d/%Y');
ALTER TABLE `loan dataset`
MODIFY COLUMN ApplicationDate DATE;

set sql_safe_updates = 0;
-- this is safe key 

-- applying the string functions
-- converting the text data
-- Here I updated educationlevel column to upper case. 

update `loan dataset`
set educationlevel = upper(educationlevel);

-- How many Employed are present in the data set and fetch their details?
select * from `loan dataset` where employmentstatus = 'employed' order by age;

-- Calculate How many applicants are loan approved and how many or not?
select loanapproved,count(*) as count 
from `loan dataset` group by loanapproved;
-- here we can see the count of loan approvals

-- applying some statistical functions like max,min,avg,count...

-- Display the maximum,minimum,average annualincome in the dataset
select max(annualincome) as max_income,
min(annualincome) as min_income,
avg(annualincome) as avg_income
from  `loan dataset`;
-- here we found max,min,avg income

-- Display all the details whose age is maximum
select * from `loan dataset`
where age = (select max(age) from `loan dataset`);
-- here we got all the details where the age is max
/* by finding the all the details whose age is maximum we can know the details of them like their education level,marital status,creditscore,annual income
how many assests they have*/

-- Display the total number of each age  according to their marital status?
SELECT age, MaritalStatus, COUNT(*) AS count,sum(LoanApproved) as loan_approved
FROM `loan dataset`
GROUP BY MaritalStatus,age order by loan_approved desc;
-- Here we can find that most of the people are from middle-age like 35-40 and they are married.This is the one of the insight to our analysis
/*here we use group by function for marital status and age so that it groups the rows of same value and performs aggregation and give the new column
so that we can know for a  particualr age group people how many members are there and their marital status.so that we can  know annualincome,creditscore 
experience of that particular people*/

-- Display some details whose age is below 35
select applicationdate,age,annualincome,creditscore,employmentstatus,educationlevel,experience,maritalstatus,homeownershipstatus,monthlyincome,riskscore 
from `loan dataset`
where age < 35; 

-- Display the average annual income and average credit score whose age is below 30
select avg(annualincome) as avg_annualincome,avg(creditscore) as avg_creditscore from `loan dataset` where age <30;
-- here we can see average annualincome and creditscore of the people whose age is below 30
-- so that we can know their status whether they are employed whether we have to approve the loan or not.

-- Find the relation between annualincome and creditscore
SELECT AnnualIncome, creditscore
FROM `loan dataset`
WHERE AnnualIncome IS NOT NULL AND creditscore IS NOT NULL;
-- here  finding some relation between annualincome and creditscore
-- it excludes the null values

-- categorising numerical data using case function
-- here we created view as agegroup 
-- view is used like it creates a temporary table but it does not store the data we can use this view as table whenever we want for the view purpose
create view agegroup as(
select *,
case
  when age < 20 then 'teen'
  when age between 20 and 30 then 'youth'
  when age between 30 and 45 then 'middle-age'
  else 'older'
end as age_group from `loan dataset`);
-- herr we is created but we can't see when we wrote the query to get the data from view it will show

select * from agegroup;
-- here we will get a new column as age_group in view purpose
-- Gettung all th data from the view which is created earlier

-- Display the count of each agegroup people?
-- we can use this view to get the count of each group so that we can analyse that which age group people are applying to the loan or taking the loan.
select age_group,count(*) from agegroup group by age_group;
-- here we can see the count of each age_group members in this dataset so that we are getting most of the midde-age people are taking he loan

select age_group,count(*),employmentstatus from agegroup where loanapproved = 1
group by age_group,loanapproved,employmentstatus
order by count(*) desc;
/* So here we can see that most of the loans are approved to the middle-aged group people 
who are employed.So we can focus loan offerings and marketing on this age group people who are employed.*/


--  Find the average credit score of the loans approved ?
select avg(creditscore) from `loan dataset` where loanapproved = 1;
-- so that we can know at what credit score they are approving the loan

-- Find the high risk loan applicants?
/* we can find the high risk loan applicants by using two factors:
1.Debt to income ratio and 2.Credit score
Firstly let us know what is debt to income ratio actually indicates:
  * It indicates how much of a person's income is allocated towards debt payments.
  * A DTI > 0.5 suggests that the  half of the person's income is already commited to debt paymnets.
  * A high DTI indicate financial strain.*/
  
/*Next let's know what is credit score indicates?
 * A credit score is the representation of the individual creditworthiness
 * It should be in the range of 300-850
 * If the creditscore is high it suggests that better credit  whereas low credit score 
 indicates higher risk
 * Generally if the credit scores are below 600 it suggests that a high credit utilisation or 
 poor credit ratings,missed payments or other financial difficulties.*/
 
/* Here why we are using these two factors means the application with high DTI indicates that 
a portion of their income is already tied up in some debt so that we can reduce their ability to take 
a new financial obligation.And also the application with low credit score indicates a higher 
missed payments or defaults.*/

/*Here we can give an insight that the application with high DTI and low creditscore are in some risk 
so that we can reject those type of applications and not approving the loan.*/

-- Here's the query:

select * from `loan dataset` where debttoincomeratio > 0.5 and creditscore < 600;
/* Here we got the 97 applications out of 1389 applications so we have a chance to reject these applications 
undoubtedly.*/
 
-- Display the count of Employment status
select employmentstatus,count(employmentstatus) as count,avg(creditscore) from `loan dataset` where loanapproved =1 group by employmentstatus,loanapproved;
/* Here we use group by and count function for employmentstatus so that we can know that the      
 count of each group in employment status*/
 -- and also we can find that the most of them are 'employed'.
 

-- In which year most of the loans are approved?
select year(applicationdate) as year,count(*) from `loan dataset` where loanapproved = 1 group by year(applicationdate) order by count(*) desc;
-- So in 2018 most of the loans got approved due to some favourable ecconomic conditions or any other loan policies.
select count(*) from `loan dataset` where year(applicationdate)=2018;
/* what is the relation between loan amount and employment status?And how it is related to 
loans approved?*/
select avg(loanamount) as avg_loan,employmentstatus from `loan dataset`
 group by employmentstatus
 order by avg_loan desc ;
-- Borrowers who are employed have the highest loanamoount


-- Display the details whose loans are approved?
select * from `loan dataset` where loanapproved = 1;
/* we can easily see that almost the people are employed,self-employed anyhow they are employed and we can see their credit score also.They have 
the good credit score*/


-- How will you categorize the borrwers by utilisation rate?
select 
case
  when CreditCardUtilizationRate < 0.3 then 'Low Utilization'
  when CreditCardUtilizationRate between 0.3 and 0.5 then 'Moderate Utilization'
  else 'High utilization'
  end as card_utilization_category,
  count(*) as borrower
from `loan dataset` where loanapproved = 1
group by card_utilization_category
order by borrower desc;
/*  Like we can understand that most of them are having 'low creitcardutilizationrate' means 
they don't have musch risk.*/


-- How many applicants are having no experience?
select count(Experience) from `loan dataset` where Experience = 0;
-- so out of 1389 rows 109 applicants have no experience 

-- Display the previous loan defaults when loan is approved?
select previousloandefaults,count(loanapproved) from `loan dataset` where loanapproved = 1 group by PreviousLoanDefaults;
-- Here maximum loan approvals are done when there is no previousloan defaults.

select riskscore,count(loanapproved) from `loan dataset` group by RiskScore order by riskscore ;
/* We can prioritize the applicants whose risk score is low we can approve the loans
for them faster.*/

select employmentstatus,riskscore,count(RiskScore),sum(loanapproved) from `loan dataset` group by RiskScore,employmentstatus order by riskscore ;
-- Here we can see that most of the loan approvals are to the applicants who are employed that to eit low credit score

SELECT LoanPurpose,count(*)
FROM `loan dataset`
GROUP BY LoanPurpose order by count(*) desc;
-- Here we can see most loans are taken for the purpose of home and debt cosolidation.
/* So we can create some special loan offers who are in need of taking the 
loan for home can attract them.

