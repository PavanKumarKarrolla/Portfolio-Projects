select * 
from CovidDeaths
where continent is not null
--lets order it by location (col-3) and date (col-4)
order by 3, 4 

delete from CovidDeaths where population is null

--The data that we will be working with
select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by location, date


--Let us look at Tatal cases Vs Total Deaths
--liklihood of dying due to covid in India
select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as Death_percentage
from CovidDeaths
where continent is not null
and location  like '%India%' --just make it as a comment if you want to get the data of all countries
order by location, date


--Total cases Vs Population
--Percentage of population who are infected with covid

select location, date, total_cases, Population ,(total_cases/population)*100 as case_percentage
from CovidDeaths
where continent is not null
and location  like '%India%'
order by 1,2

--checking the country with Maximum rate of cases

select location, Population, MAX(total_cases) as Maximum_cases_count, Max(total_cases/population)*100 as case_percentage
from CovidDeaths
where continent is not null
Group by location,population
order by 4 desc 

--checking the country with Maximum rate of deaths

select location, MAX(cast(total_deaths as int)) as Maximum_death_count
from CovidDeaths
where continent is not null
Group by location 
order by 2 desc 

--checking the continent with Maximum rate of deaths

select continent, MAX(cast(total_deaths as int)) as Maximum_death_count
from CovidDeaths
where continent is not null
Group by continent
order by 2 desc 

--GLOBAl numbers

select date, sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths,
(sum(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from CovidDeaths
where continent is not null
--Group by date --If we make this line as comment and remove date from the first line 
                 --it will give us one row with the selected columns
order by 1,2


--Joining tables
--And Total Population Vs Total Vaccination

select Deaths.continent, Deaths.location,Deaths.date,Deaths.population,Vaccination.new_vaccinations,
SUM(convert(bigint,Vaccination.new_vaccinations)) 
	over (partition by Deaths.location order by Deaths.location, Deaths.date) as Rolling_vaccinations
from CovidDeaths Deaths
Join covidVaccination Vaccination
	on Deaths.location=Vaccination.location
	and Deaths.date=Vaccination.date
where Deaths.continent is not null
order by 2,3




--CTE
with popVsVac (continent, location, date, population, New_vaccination, Rolling_vaccinations)
as
(
select Deaths.continent, Deaths.location,Deaths.date,Deaths.population,Vaccination.new_vaccinations,
SUM(convert(bigint,Vaccination.new_vaccinations)) 
	over (partition by Deaths.location order by Deaths.location, Deaths.date) as Rolling_vaccinations
from CovidDeaths Deaths
Join covidVaccination Vaccination
	on Deaths.location=Vaccination.location
	and Deaths.date=Vaccination.date
where Deaths.continent is not null
)
select *,(Rolling_vaccinations/population)*100 as vacc_Percentage
From popVsVac

--or you can run the below one

--select locaion,Max(Rolling_vaccinations/population)*100 as vacc_Percentage
--From popVsVac
--group by location



--TEMP TABLE

Drop table if exists #Vacc_Percent
Create table #Vacc_Percent
( continent nvarchar(200),
location nvarchar(200),
date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_vaccinations numeric
)
Insert into #Vacc_Percent
select Deaths.continent, Deaths.location,Deaths.date,Deaths.population,Vaccination.new_vaccinations,
SUM(convert(bigint,Vaccination.new_vaccinations)) 
	over (partition by Deaths.location order by Deaths.location, Deaths.date) as Rolling_vaccinations
from CovidDeaths Deaths
Join covidVaccination Vaccination
	on Deaths.location=Vaccination.location
	and Deaths.date=Vaccination.date
where Deaths.continent is not null

--select *,(Rolling_vaccinations/population)*100 as vacc_Percentage
--From #Vacc_Percent

select location, population, Max(Rolling_vaccinations/population)*100 as vacc_Percentage
From #Vacc_Percent
group by location, Population
order by 1


--Creating VIEW to store data

create view Vacc_Percent as 
select Deaths.continent, Deaths.location,Deaths.date,Deaths.population,Vaccination.new_vaccinations,
SUM(convert(bigint,Vaccination.new_vaccinations)) 
	over (partition by Deaths.location order by Deaths.location, Deaths.date) as Rolling_vaccinations
from CovidDeaths Deaths
Join covidVaccination Vaccination
	on Deaths.location=Vaccination.location
	and Deaths.date=Vaccination.date
where Deaths.continent is not null

select *
from Vacc_Percent


--tableau table 2

select location, sum(cast(new_deaths as int)) as Total_Deaths
from CovidDeaths
where continent is null
and location not in ('World', 'High income', 'upper middle income','lower middle income', 'low income','European union')
Group by location
order by Total_Deaths desc


--tableau table 3

select location, Population, MAX(total_cases) as Maximum_cases_count, Max(total_cases/population)*100 as case_percentage
from CovidDeaths
where continent is not null
Group by location,population
order by 4 desc 


--tableau table 4
select location, Population,date, MAX(total_cases) as Maximum_cases_count, Max(total_cases/population)*100 as case_percentage
from CovidDeaths
where continent is not null
Group by location,population,date
order by 4 desc 
