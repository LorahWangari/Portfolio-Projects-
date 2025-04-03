select * 
from covid.coviddeaths;

select* 
from covid.covidvaccinations;

-- Select data we are going to be using --

select location, date ,total_cases, new_cases, total_deaths, population 
from covid.coviddeaths
where continent is not null 
order by 1, 2;

-- Looking at total cases vs total deaths --
-- Shows likelihood of dying if you contract covid in your country --

select location, date ,total_cases, total_deaths, (total_deaths/ total_cases) * 100 as death_percentage
from covid.coviddeaths
where location like 'unitedkingdom'
and continent is not null 
order by 1, 2;

-- Looking at total cases vs population --
-- Shows what percentage of population got covid --

select location, date , total_cases, population, ( total_cases/population) * 100 as percent_of_population_infected
from covid.coviddeaths
where location like 'Africa'
and continent is not null 
order by 1, 2;

-- Looking at countries with highest infection rate compared to population --

select location, population, max(total_cases) as highest_infection_rate, max( total_cases/population) * 100 as percent_of_population_infected
from covid.coviddeaths
where continent is not null 
group by location, population 
order by percent_of_population_infected desc;

-- Showing the countries with the highest death count per population --

select location, max(total_deaths) as total_death_count 
from covid.coviddeaths
where continent is not null 
group by location 
order by total_death_count desc;

-- Break it down by continent --

select continent, max(total_deaths) as total_death_count 
from covid.coviddeaths
where continent is not null 
group by continent 
order by total_death_count desc;

-- Showing the continents with the highest death counts --

select continent, max(total_deaths) as total_death_count 
from covid.coviddeaths
where continent is not null 
group by continent 
order by total_death_count desc;

-- global numbers --

select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/ sum(new_cases)  *100 as death_percentage 
from covid.coviddeaths
where continent is not null 
group by date
order by 1, 2;

-- Looking at total population vs vaccinations -- 

select* 
from covid.coviddeaths as dea 
join covid.covidvaccinations as vac;

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from covid.coviddeaths dea
join covid.covidvaccinations vac
	on dea.location = vac.location 
    and dea.date = vac.date
where dea.continent is not null
order by 2,3; 

-- Use CTE -- 

with PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from covid.coviddeaths dea
join covid.covidvaccinations vac
	on dea.location = vac.location 
    and dea.date = vac.date
where dea.continent is not null
order by 2,3
)
select* , (rolling_people_vaccinated/population) *100
from PopvsVac;

-- Temp table -- 

drop table if exists PercentagePopulationVaccinated
create table PercentagePopulationVaccinated
(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric, 
rolling_people_vaccinated numeric
)
insert into PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, coalesce(vac.new_vaccinations, 0),
sum(coalesce(vac.new_vaccinations, 0) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from covid.coviddeaths dea
join covid.covidvaccinations vac
	on dea.location = vac.location 
    and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select* , (rolling_people_vaccinated/population) *100
from PopvsVac;


-- Creating view to store date for later visualization --

create view TotalDeathCount as
select continent, max(total_deaths) as total_death_count 
from covid.coviddeaths
where continent is not null 
group by continent 
order by total_death_count desc;

select* 
from totaldeathcount;



