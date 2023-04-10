SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM ['coviddeath$']
order by 1,2
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM ['coviddeath$']
order by 1,2
SELECT Location, date, population, total_cases, (total_cases/population)*100 as CasePercentage
FROM ['coviddeath$']
order by 1,2
SELECT Location, population, date, MAX(total_cases) as highestInfectionCount, MAX((total_cases/population))*100 as CasePercentage
FROM PortfolioProject..['coviddeath$']
Where continent is not null
Group by location, population, date
order by CasePercentage desc
SELECT continent, MAX(CAST(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..['coviddeath$']
Where continent is not null
Group by continent
Order by TotalDeathCount desc
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM PortfolioProject..['coviddeath$']
where continent is not null
order by 1,2
SELECT location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..['coviddeath$']
Where continent is not null
and location not in ('world', 'European Union', 'International')
Group by location
Order by TotalDeathCount desc

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM ['coviddeath$'] dea
JOIN ['covidvaccinations$'] vac
    on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int,vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM ['coviddeath$'] dea
JOIN ['covidvaccinations$'] vac
    on dea.location = vac.location
	and dea.date = vac.date
Where continent is not null
order by 2,3
With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeoplVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int,vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM ['coviddeath$'] dea
JOIN ['covidvaccinations$'] vac
    on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
SELECT *, (RollingPeoplVaccinated/population)*100 as percentagepopulationvaccinated
FROM PopvsVac

Create View percentagepopulationvaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) over(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM ['coviddeath$'] dea
JOIN ['covidvaccinations$'] vac
    on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null