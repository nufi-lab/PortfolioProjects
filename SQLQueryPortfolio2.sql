Select *
From PortfolioProject..covidDeaths
Where continent is not null
order by 3, 4

--Select *
--From PortfolioProject..covidVaccinations
--order by 3, 4

-- Select data that we are going to be use
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..covidDeaths
Where continent is not null
order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as deathPercentage
From PortfolioProject..covidDeaths
where location like '%indo%'
and continent is not null
order by 1, 2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
Select location, date, population, total_cases, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as percentPopulationInfected
From PortfolioProject..covidDeaths
where location like '%indo%'
and continent is not null
order by 1, 2

-- Looking for Countries with Highest Infection rates compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)))*100 as percentPopulationInfected
From PortfolioProject..covidDeaths
where location like '%indone%'
and continent is not null
Group by location, population
order by percentPopulationInfected desc

-- Showing countries with highest death count per population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..covidDeaths
where continent is not null
group by location, population
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

-- Showing worldwide total cases and total deaths
select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercetage
FROM PortfolioProject..covidDeaths
where continent is not null
--group by date
order by 1, 2

-- JOIN TABLE
select *
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

-- Looking at Total Population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..covidDeaths dea
	join PortfolioProject..covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- USE CTE
with PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)

select *, (RollingPeopleVaccinated/Population)*100 
from PopvsVac

--TEMP TABLE

drop table if exists #percentPopulationVaccinated
create table #percentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #percentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3

select *, (RollingPeopleVaccinated/Population)*100 
from #percentPopulationVaccinated

-- creating view to store for later visualizations
CREATE VIEW percentagePopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

select * from percentagePopulationVaccinated