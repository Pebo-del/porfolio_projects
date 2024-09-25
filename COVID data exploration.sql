select * from portfolio_projects..CovidDeaths;

--lookig at total cases vs total deaths

select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
from portfolio_projects..CovidDeaths
where location like '%states%' and
  continent is not null
order by 1,2;   
--looking at total cases vs population
--shows what percentage of population got covid

select location,date,population,total_cases, (total_cases/population)*100 as patient_percentage
from portfolio_projects..CovidDeaths
--where location like '%states%'
where continent is not null
order by 1,2;

--looking at countries with highest infectionrate

select location,population,max(total_cases) as highest_infection_count, max((total_cases/population))*100 as percentageinfected
from portfolio_projects..CovidDeaths
--where location like '%states%'
where continent is not null
group by population,location
order by percentageinfected desc;  


--countries with highest deaths

select location,max(cast(total_deaths as int)) as highest_deaths 
from portfolio_projects..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by highest_deaths desc; 

--lets break things down  by continents


select  continent,max(cast(total_deaths as int)) as highest_deaths
from portfolio_projects..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by highest_deaths desc;      

--showing continents with the highest death count per population

select  continent,max(cast(total_deaths as int)) as highest_deaths
from portfolio_projects..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by highest_deaths desc;

-- GLOBAL NUMBERS

 select SUM(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/SUM(new_cases)*100
 as deathpercent--total_deaths, (total_deaths/total_cases)*100 as death_percentage
from portfolio_projects..CovidDeaths
--where location like '%states%' and
 where continent is not null
-- group by date 
order by 1,2;


select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
--
from portfolio_projects..CovidDeaths dea
join portfolio_projects..CovidVaccinations vac
on dea.location=vac.location and
dea.date=vac.date
where dea.continent is not null
order by 2,3   



--use CTE
with popvscav (continent,location,date,population,rolling_people_vaccinated,new_vaccinations)
as(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
--
from portfolio_projects..CovidDeaths dea
join portfolio_projects..CovidVaccinations vac
on dea.location=vac.location and
dea.date=vac.date
where dea.continent is not null
--order by 2,3 
)
select*, (rolling_people_vaccinated/population)*100 as rolling_percentage
from popvscav  


--creating view to store data for later visualization

create view percent_pop_vaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
--
from portfolio_projects..CovidDeaths dea
join portfolio_projects..CovidVaccinations vac
on dea.location=vac.location and
dea.date=vac.date
where dea.continent is not null
--order by 2,3 

select* 
from percent_pop_vaccinated

