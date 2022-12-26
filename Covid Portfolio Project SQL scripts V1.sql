use PortfolioProjectProject



select location, date, total_cases, new_cases, total_deaths, population
from Covid_Deaths order by 1,2



-- Death Percentage

select location, date, total_cases,total_deaths, round((total_deaths/total_cases)*100,2) as Death_percentage
from Covid_Deaths where continent is not null order by 1,2 

-- Total cases Vs Population ( How much % of population is infected by virus till date)

select location, date, population, total_cases,round((total_cases/population)*100,2) as Infection_percentage
from Covid_Deaths where continent is not null order by 1,2 



-- 3. COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION :

select location, population,max(total_cases) as Total_infection_count, 
max(round((total_cases/population)*100,2)) as Total_Infection_percentage
from Covid_Deaths where continent is not null 
group by location,population order by Total_Infection_percentage desc



-- 4. COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION DATEWISE:

select location, population,date,
max(total_cases) as Total_infection_count, 
max(round((total_cases/population)*100,2)) as Total_Infection_percentage
from Covid_Deaths where continent is not null 
group by location,population,date
order by Total_Infection_percentage desc



-- COUNTRIES WITH HIGHEST DEATH RATE COMPARED TO POPULATION :

select location,max(cast(total_deaths as int)) as Highest_Death_count
from Covid_Deaths where continent is not null group by location order by Highest_Death_count desc



-- Continent wise Death count including World, International, European Union & Based on Income 

select location,max(cast(total_deaths as int)) as Total_Death_count
from Covid_Deaths where continent is null group by location order by Total_Death_count desc



-- 2. Continent wise Death Count

select location,max(cast(total_deaths as int)) as Total_Death_count
from Covid_Deaths where continent is null and location not in ('World','High income','Upper middle income','Lower middle income','European Union','Low income','International')
group by location order by Total_Death_count desc




-- Numbers Across World Date-wise

select date,SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
round(sum(cast(new_deaths as int))/sum(new_cases)*100,2) as total_death_percentage
from Covid_Deaths where continent is not null
group by date order by date


-- 1. Numbers Across World Aggregated

select SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
round(sum(cast(new_deaths as int))/sum(new_cases)*100,2) as total_death_percentage
from Covid_Deaths where continent is not null




use PortfolioProjectProject
select * from PortfolioProjectProject.dbo.Covid_Vaccinations
where continent is not null




-- Total Population Vs Vaccinations

with cte (continent,location,date,population,new_vaccinations, Running_Total_vaccn)
as

(select d.continent, d.location, d.date,d.population,v.new_vaccinations,
sum(convert(bigint,d.new_vaccinations)) over (partition by d.location order by d.location, d.date) as Running_Total_vaccn
from Covid_Deaths d
join Covid_Deaths v
on d.location = v.location and
d.date = v.date
where d.continent is not null)
select *,round((Running_Total_vaccn/population)*100,2) as Running_Total_vaccn_percentage from cte




-- Total Booster Doses & Booster Percentage Administered for whole Population


select location,population, max(cast(total_boosters as bigint)) as total_boosters,
round((max(cast(total_boosters as bigint))/population)*100,2) as booster_percentage
from Covid_Deaths
where continent is not null
group by location,population
order by 4 desc




-- Create view for Total Vaccination of population

create view Total_People_Vaccinated as
select d.continent, d.location, d.date,d.population,v.new_vaccinations,
sum(convert(bigint,d.new_vaccinations)) over (partition by d.location order by d.location, d.date) as Running_Total_vaccn
from Covid_Deaths d
join Covid_Deaths v
on d.location = v.location and
d.date = v.date
where d.continent is not null



select * from Total_People_Vaccinated

