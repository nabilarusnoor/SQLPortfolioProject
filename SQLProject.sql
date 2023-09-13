-- Select which dataset

-- Dataset 1
select *
from portfolioproject.dbo.coviddeaths
where continent is not null
order by 3,4

-- Dataset 2
select *
from portfolioproject.dbo.covidvaccinations
order by 3,4

-- Select data values that is gonna be used

select location, date, total_cases, new_cases, total_deaths, population
from portfolioproject.dbo.coviddeaths
order by 1,2

-- Looking at total cases vs total deaths
-- Shows the likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolioproject.dbo.coviddeaths
where location = 'United Kingdom'
order by 1,2

-- Looking at total cases vs population
-- Shows what percentage of population got covid

select location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
from portfolioproject.dbo.coviddeaths
where location like '%states%'
order by 1,2

-- Looking at countries with highest infection rate compared to population

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPercentage
from portfolioproject.dbo.coviddeaths
--where location like '%states%'
group by location, population
order by InfectedPercentage desc

-- Showing countries with highest death count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from portfolioproject.dbo.coviddeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

-- Breaking things down by continent
-- Showing the continents with highest death count 

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from portfolioproject.dbo.coviddeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global numbers

-- Total cases, total deaths and death percentage by DAY

select date as 'Date', SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from portfolioproject..coviddeaths
where continent is not null
group by date
order by 1,2

-- Total cases, total deaths and death percentage in general

select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from portfolioproject..coviddeaths
where continent is not null
order by 1,2

-- Looking at total population vs vaccinations

-- Basic query

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as cumulativevaccinations
from portfolioproject..coviddeaths dea
join portfolioproject..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using CTE to find total population vs vaccinations after the basic query

with popsvsvac (continent, location, date, population, new_vaccinations, cumulativevaccinations) as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as cumulativevaccinations
from portfolioproject..coviddeaths dea
join portfolioproject..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

select *, (cumulativevaccinations/population)*100 as cumulativevacpercentage
from popsvsvac

-- Using temp table to find total population vs vaccinations after the basic query

drop table if exists #percentagepopulationvaccinated
create table #percentagepopulationvaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
cumulativevaccinations numeric
)

insert into #percentagepopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as cumulativevaccinations
from portfolioproject..coviddeaths dea
join portfolioproject..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (cumulativevaccinations/population)*100 as cumulativevacpercentage
from #percentagepopulationvaccinated

-- Creating view to store data for later visualisations

create view percentagespopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as cumulativevaccinations
from portfolioproject..coviddeaths dea
join portfolioproject..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from percentagespopulationvaccinated

