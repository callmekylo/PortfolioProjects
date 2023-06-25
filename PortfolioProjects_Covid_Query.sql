select *
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject.dbo.CovidVaccinations
--order by 3,4

--select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 1,2

--looking at the total cases vs total deaths
--shows the likekyhood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, round(((total_deaths / total_cases) * 100), 2) as fatality_rate
from CovidDeaths
where location like'united states%' and continent is not null
order by 1,2 asc

--looking at the total_cases vs population
--shows what pct of population got covid

select location, date, population, total_cases, round(((total_cases / population) * 100), 2) as population_positive_rate
from CovidDeaths
where location like'united states%' and continent is not null
order by 1,2 asc

--looking at which locations has the highest infection rates compared to population

select location, population, max(total_cases) as highest_infection_count, max((total_cases / population) * 100) as population_positive_rate
from CovidDeaths
where continent is not null
group by location, population
order by population_positive_rate desc

--showing location with highest death count per population

select location, max(cast(total_deaths as int)) as total_death_count
from CovidDeaths
where continent is not null
group by location
order by total_death_count desc

--showing continent with highest death count per population

select location, max(cast(total_deaths as int)) as total_death_count
from CovidDeaths
where continent is null
group by location
order by total_death_count desc

--global numbers

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int)) / sum(new_cases) * 100 as world_death_pct--, total_deaths, round(((total_deaths / total_cases) * 100), 2) as fatality_rate
from CovidDeaths
where continent is not null
group by date
order by 1,2 asc

--total population vs vacinations

select dea.date, dea.continent, dea.location, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as rolling_people_vaccinated--, ((rolling_people_vaccinated / population) * 100)
from CovidDeaths as dea
inner join CovidVaccinations as vac
	on dea.date = vac.date and dea.location = vac.location
where dea.continent is not null
order by 3,1

--using a cte

with pop_vs_vac (date, continent, location, population, new_vaccinations, rolling_people_vaccinated)
as
(
select dea.date, dea.continent, dea.location, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as rolling_people_vaccinated--, ((rolling_people_vaccinated / population) * 100)
from CovidDeaths as dea
inner join CovidVaccinations as vac
	on dea.date = vac.date and dea.location = vac.location
where dea.continent is not null
--order by 3,1
)
select *, ((rolling_people_vaccinated / population) * 100) as vaccination_rate
from pop_vs_vac
order by 3,1

--using a temp table

drop table if exists #pct_population_vaccinated
create table #pct_population_vaccinated
(
date datetime, 
continent nvarchar(255), 
location nvarchar(255), 
population int, 
new_vaccinations int, 
rolling_people_vaccinated int
)

insert into #pct_population_vaccinated
select dea.date, dea.continent, dea.location, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as rolling_people_vaccinated--, ((rolling_people_vaccinated / population) * 100)
from CovidDeaths as dea
inner join CovidVaccinations as vac
	on dea.date = vac.date and dea.location = vac.location
where dea.continent is not null
--order by 3,1

select *, ((rolling_people_vaccinated / population) * 100) as vaccination_rate
from #pct_population_vaccinated

--creating views to store data for later visulizations

create view pct_population_vaccinated as
select dea.date, dea.continent, dea.location, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as rolling_people_vaccinated--, ((rolling_people_vaccinated / population) * 100)
from CovidDeaths as dea
inner join CovidVaccinations as vac
	on dea.date = vac.date and dea.location = vac.location
where dea.continent is not null
--order by 3,1

select *
from pct_population_vaccinated