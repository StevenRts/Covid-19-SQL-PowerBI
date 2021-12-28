select *
From CovidProject..[CovidDeaths]
where continent is not null
order by 3,4

--select *
--From CovidProject..[Covid Vaccinations]
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From CovidProject..[CovidDeaths]
where continent is not null
order by 1,2

--looking at Total Cases vs Total Deaths
--Shows likelyhood of dieing if you contrat COVID-19 in the United States
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject..[CovidDeaths]
where location like '%United states%'
and continent is not null
order by 1,2

--Looking at the Total Cases vs Population
--Shows what percentage of population contracted Covid-19
Select location, date, Population, total_cases, (total_cases/Population)*100 as PercentPopulationInfected
From CovidProject..[CovidDeaths]
Where location like '%United States%'
and continent is not null
order by 1,2

--Looking at Countries with highest infection rate compared to Population
Select location, Population, MAX(total_cases) as Highestinfectioncount, MAX((total_cases/Population)*100) as PercentPopulationInfected
FROM CovidProject..[CovidDeaths]
where continent is not null
group by location, Population
order by PercentPopulationInfected desc

-- Showing the Countries with the Highest Death Count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidProject..[CovidDeaths]
where continent is not null
group by location
order by TotalDeathCount desc

-- showing the continents with the highest deathcounts

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidProject..[CovidDeaths]
where continent is null
group by location
order by TotalDeathCount desc

-- Show Global Numbers by date

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidProject..[CovidDeaths]
--where location like '%United states%'
where continent is not null
group by date
order by 1,2

--Show Global Numbers total

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidProject..[CovidDeaths]
--where location like '%United states%'
where continent is not null
--group by date
order by 1,2

 --Looking at total vaccination vs population

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
From CovidProject..CovidDeaths dea
join CovidProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3

 --USE CTE
With popvsvac (Continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
 (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
From CovidProject..CovidDeaths dea
join CovidProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
)
Select*
From popvsvac

With popvsvac (Continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
 (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
From CovidProject..CovidDeaths dea
join CovidProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
)
Select*, (rollingpeoplevaccinated/population)*100 as percentpopvaccinated
From popvsvac

--Temp table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
From CovidProject..CovidDeaths dea
join CovidProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
--where dea.continent is not null

Select *, (rollingpeoplevaccinated/population)*100
From #PercentPopulationVaccinated

-- creating view to store for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
From CovidProject..CovidDeaths dea
join CovidProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
