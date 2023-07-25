use Project;

select * from project.dbo.data1;

select * from project.dbo.data2;

--number of rows into our datasets

select COUNT(*) from project..data1;

select COUNT(*) from project..data2;

-- Calculate the dataset for jharkhand and Bihar

select * from project..data1
where State in ('jharkhand','Bihar');

--Population of India

select sum(Population) population from project..data2;

--average growth of India

select avg(Growth)*100 avg_growth from project..data1;

--avg state 

select state, avg(Growth)*100 avg_growth from project..data1
group by state;

--avg sex ration

select state, round(avg(Sex_Ratio),0) avg_sex_ration from project..data1
group by state
order by avg_sex_ration desc;

--avg_litracy_rate

select state, round(avg(Literacy),0) avg_literacy_rate from project..data1
group by state
having round(avg(Literacy),0)>90 order by avg_literacy_rate desc;

--top 3 states highest growth ration
select * from project..Data1;

select top 3state, avg(growth)*100 avg_growth from project..data1
group by state
order by avg_growth desc;

-- bottom 3 states showing lowest sex ratio
select top 3 state, round(avg(Sex_Ratio),0) avg_sex_ratio from project..data1
group by state
order by avg_sex_ratio asc;

--top and bottom 3 states in literacy state
drop table if exists #topstates
create table #topstates
(state nvarchar(255),
topstates float

 )

insert into #topstates
select state, round(avg(literacy),0) avg_literacy_ratio from project..data1
group by state
order by avg_literacy_ratio asc;

select top 3 * from #topstates order by #topstates.topstates desc;

--------------------------------------------------------------------------------------------

drop table if exists #bottomstates;
create table #bottomstates
(state nvarchar(255),
bottomstates float

 )

insert into #bottomstates
select state, round(avg(literacy),0) avg_literacy_ratio from project..data1
group by state
order by avg_literacy_ratio asc;

select top 3 * from #bottomstates order by #bottomstates.bottomstates asc;

--union operator
select * from (
select top 3 * from #topstates order by #topstates.topstates desc) a

union

select * from (
select top 3 * from #bottomstates order by #bottomstates.bottomstates asc)b;


--- states starting with letter a or any other word we used 

select distinct state from project..Data1 where lower(state) like 'a%' or lower(state) like 'b%';

select distinct state from project..Data1 where lower(state) like 'a%' and lower(state) like '%m';

