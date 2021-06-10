
---------- All Perfromance data loaded in PVData2 table ----------------

SELECT *
FROM [Capstone].[dbo].[PVData2]
order by timestamp



-------------- Normalised Power Generation for all loctions considering 5kWp PV System size and create a new table PVData ------------
  
 --- Drop table PVData

  SELECT *,
  Format (timestamp,'yyyy-MM-dd HH:mm' ) DateTime,
  cast(Timestamp as date) Date,
  Format (timestamp,'HH:mm') Time,
  round (case when Location = 'Canterbury (NSW)' then [PV Yield (kWh)]*5/3.06
			  when Location = 'Sutherland (NSW)' then [PV Yield (kWh)]*5/5.04
			   when Location = 'St Ives (NSW)' then [PV Yield (kWh)]*5/5.1
			   when Location = 'Newtown (NSW)' then [PV Yield (kWh)]*5/5.1
				 else 0 end ,2) [PV Yield (5KWp)]
  into PVData
  FROM [Capstone].[dbo].[PVData2]

 
  
 ------------ Select some records for report ------------

  select top (3) * from PVData
  where location = 'Canterbury (NSW)' 
  union all
  select top (3) * from PVData
  where location = 'Sutherland (NSW)'
  union all
  select top (3) * from PVData
  where location = 'St Ives (NSW)'
  union all
  select top (3) * from PVData
  where location ='Newtown (NSW)'



  ----------------- Create a table with Canterbury data only ---------

  SELECT *
  into [dbo].PVData_Canterburry
  FROM PVData
  where Location = 'Canterbury (NSW)'
  and year(date) >= '2012'


  
----------create a table for missing dates of Canterbury data------------

 select FullDateAlternateKey
 into [Canterbury_Missing_Dates]
  from DimDate
  where yearcode >= '2012'
  and FullDateAlternateKey<'2021-04-01'
  except 
  select distinct date
  from [dbo].PVData_Canterburry
  where year(date) >= '2012'
  and date<'2021-04-01'
  order by FullDateAlternateKey



  update [Canterbury_Missing_Dates]
  set FullDateAlternateKey = cast (FullDateAlternateKeyas date)


------- Select records for Sutherland location for Canterbury missing dates--------------

select a.* from 
  PVData a inner join [Canterbury_Missing_Dates] b
  on a.date =cast (b.FullDateAlternateKey as date)
  and location  = 'Sutherland (NSW)'
  and b.[Other Source] = 'Sutherland'

---------------- Insert into Canterbury Dataset -------------------


insert into PVData_Canterbury
select a.* from 
  PVData a inner join [Canterbury_Missing_Dates] b
  on a.date =cast (b.FullDateAlternateKey as date)
  and location  = 'Sutherland (NSW)'
  and b.[Other Source] = 'Sutherland'


------- Select records where location is Newtown for rest missing dates of Canterbury-------------

select a.* from 
  PVData a inner join [Canterbury_Missing_Dates] b
  on a.date =cast (b.FullDateAlternateKey as date)
  and location  = 'Newtown (NSW)'
  and b.[Other Source] = 'Newton'

---------- insert into -----------

insert into PVData_Canterbury
select a.* from 
  PVData a inner join [Canterbury_Missing_Dates] b
  on a.date =cast (b.FullDateAlternateKey as date)
  and location  = 'Newtown (NSW)'
  and b.[Other Source] = 'Newton'


------------- Data Check for Missing Time ---------------

select * from PVData_Canterbury


select  
year(date) year,
count(distinct date) count
from PVData_Canterbury
group by year(date)

------------

select  
date,
count(*) count
from PVData_Canterbury
group by date
order by date


-------- Missing TimeStamp in Canterbury data -----------


select * from DimTime
where timevalue>='2012-01-01'
and timevalue not in 
 (
 select Timestamp from PVData_Canterbury
 )
and  id%2!=1

 ---------------------------------

 insert into PVData_Canterbury
 
 select a.* from PVData a inner join
	(select * from DimTime
			where timevalue>='2012-01-01'
			and  id%2!=1
			and timevalue not in 
			 (
			 select Timestamp from PVData_Canterbury
			 )
	)b
on a.Timestamp = b.TIMEVALUE

--and year(a.Timestamp) in (2020,2021)
--and a.location  = 'Newtown (NSW)'

---------- Data checking------------------------------- 

select 
distinct
Time
from PVData_Canterbury
where [PV Yield (5KWp)] >0
order by Time

-----------------------------------

select 
max(Time) MaxTime_PVGeneration,
min(Time) MinTime_PVGeneration
from PVData_Canterbury
where [PV Yield (5KWp)] >0

----------------------------------------

select * from  PVData
where [PV Yield (5KWp)] >0
and date = '2017-02-27'
and time ='17:00'

------------ Insert those missing time for those the PV generation is zero ---
/*
MaxTime_PVGeneration	MinTime_PVGeneration
20:00					05:00
*/

select * from  PVData_Canterbury

insert into PVData_Canterbury
select 
'Canterbury (NSW)' Location,
TIMEVALUE,
null,
null,
null,
0,
0,
Format (timevalue,'yyyy-MM-dd HH:mm' ) DateTime,
  cast(timevalue as date) Date,
  Format (timevalue,'HH:mm') Time

from DimTime
	where timevalue>='2012-01-01'
	and  id%2!=1
	and timevalue not in 
		(
		select Timestamp from PVData_Canterbury
		)
	and (Format (timevalue,'HH:mm') >= '20:00' 
	or Format (timevalue,'HH:mm') <= '05:00')



-------------Insert all 30 min interval time in main DataSet ---------------

insert into PVData_Canterbury 
select 
'Canterbury (NSW)-30min' Location,
TIMEVALUE,
null,
null,
null,
0,
0,
Format (timevalue,'yyyy-MM-dd HH:mm' ) DateTime,
  cast(timevalue as date) Date,
  Format (timevalue,'HH:mm') Time
from DimTime
where timevalue>='2012-01-01'
and timevalue not in 
 (
 select Timestamp from PVData_Canterbury
 )
and  id%2!=0

---------------------PV Final DataSet Prep---------------------

-------- Date wise count check (48 records for each day) ------
select 
date,
count(*) count 
from PVData_Canterbury 
group by date
having count(*) != 48



select date, sum([PV Yield (5KWp)]) from PVData_Canterbury
group by date
order by sum([PV Yield (5KWp)]) desc


--------------------------------------------------------------------------------------

select sum([PV Yield (5KWp)]) from PVData_Canterbury  ---- 31.40
where date = '2012-01-01' 
order by time 
--------------------------------------------


------------------ Added new Column with updated PV to make 30 min interval production

---- drop table PVPerformanceData_NSW

select 
RANK () over (order by Timestamp) rankNo,
Timestamp,
DateTime,
Date,
Time,
[Nearest BOM station temperature (C)],
[PV Yield (kWh)],
[PV Yield (5KWp)],
sum([PV Yield (5KWp)]*.5) OVER (ORDER BY Timestamp ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING)  [PV Yield KWh (5KWp System)] 

into PVPerformanceData_NSW
from PVData_Canterbury  
--where time > '05:00' 
--and time <= '20:00'
--and date >='2012-01-01' and date <= '2012-01-03' 
order by date, time 


----------------------------------------
Select * from PVPerformanceData_NSW


Select 
Date,
sum([PV Yield KWh (5KWp System)]),
sum([PV Yield (5KWp)]),
sum([PV Yield KWh (5KWp System)]- [PV Yield (5KWp)]) Diff
from PVPerformanceData_NSW
group by Date
having sum([PV Yield KWh (5KWp System)]- [PV Yield (5KWp)])!= 0
order by date


------------- NSW and ACT Total Installation -----------

select * from [dbo].[PVCumulativeInstallationNSW_ACT]



----select * from [dbo].[ACTPerMonthInstallation]

/*

select 
Month, 
[Capacity (kW)],
sum([Capacity (kW)]) OVER (order by Month) as [RunningTotal(kW)]
into [ACTCumulativeInstallation]
from [dbo].[ACTPerMonthInstallation]

select * from [ACTCumulativeInstallation]





------------ PV NSW Cumulative Installation ----------

select 
na.Month YearMonth,
cast (SUBSTRING(na.Month,1,4) as int) Year,
cast (SUBSTRING(na.Month,6,2) as int) Month,

na.[Total Size (KW)] [NSWACTSize(kW)],
a.[RunningTotal(kW)] [ACTSize(kW)],
na.[Total Size (KW)] - a.[RunningTotal(kW)] [NSWTotalSize(kW)]

into PVCumInstallationNSW
from [dbo].[PVCumulativeInstallationNSW_ACT] na left join [ACTCumulativeInstallation] a
on na.Month = a.Month

---------


select * from PVCumInstallationNSW
where Year>=2012

select * from PVCumInstallationNSW
where YearMonth = '2021-03'

-------------- NSW Total Generation from 2012 to Mar 2021 -----------

Select 
pn.DateTime,
pn.Date,
pn.Time,
pn.[Nearest BOM station temperature (C)],
pn.[PV Yield KWh (5KWp System)],
ni.[NSWTotalSize(kW)]/1000 [NSWTotalSize(MW)],
cast (round(pn.[PV Yield KWh (5KWp System)] * ni.[NSWTotalSize(kW)] / 5000,0) as int) [PVGeneration(MW)]
into NSW_PV_Data_2012_032021
from PVPerformanceData_NSW pn left join PVCumInstallationNSW ni
on Year(pn.Date) = ni.Year and Month(pn.Date) = ni.Month
order by Date


------------------------------------------

select * from NSW_PV_Data_2012_032021
order by DateTime 

 -----------------------

 -------------- NSW & ACT Total Generation  from 2012 to Mar 2021 -----------

Select 
pn.DateTime,
pn.Date,
pn.Time,
pn.[Nearest BOM station temperature (C)],
pn.[PV Yield KWh (5KWp System)],
ni.[Total Size (KW)] /1000 [NSWACTTotalSize(MW)],
cast (round(pn.[PV Yield KWh (5KWp System)] * ni.[Total Size (KW)]  / 5000,0) as int) [PVGeneration(MW)]
into NSWACT_PV_Data_2012_032021
from PVPerformanceData_NSW pn left join [PVCumulativeInstallationNSW_ACT] ni
on Year(pn.Date) = cast (SUBSTRING(ni.Month,1,4) as int) 
and Month(pn.Date) = cast (SUBSTRING(ni.Month,6,2) as int) 
order by Date

--------------------------

 */
 -------------- NSW & ACT Total Generation (excluded PV 30+ MW) from 2012 to Mar 2021 -----------

Select 
pn.DateTime,
pn.Date,
pn.Time,
pn.[Nearest BOM station temperature (C)],
pn.[PV Yield KWh (5KWp System)],
(ni.[Total Size (KW)] - ni.[30+ MW])/1000 [NSWACTTotalSize(MW)],
cast (round(pn.[PV Yield KWh (5KWp System)] * (ni.[Total Size (KW)] - ni.[30+ MW]) / 5000,0) as int) [PVGeneration(MW)]
into NSWACT_PV_Data_30MW_Excluded_2012_032021
from PVPerformanceData_NSW pn left join [PVCumulativeInstallationNSW_ACT] ni
on Year(pn.Date) = cast (SUBSTRING(ni.Month,1,4) as int) 
and Month(pn.Date) = cast (SUBSTRING(ni.Month,6,2) as int) 
order by Date

--------------------------

select DateTime,
[PVGeneration(MW)]
from NSWACT_PV_Data_30MW_Excluded_2012_032021
order by DateTime





