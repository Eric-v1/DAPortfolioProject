Select *
From PortfolioProject..CovidDeaths
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at the total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths,
CASE 
	When total_cases = 0 THEN 0
	Else CAST (total_deaths as FLOAT) / total_cases * 100 
	End as DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'France'
order by 1,2

-- Looking at total cases vs population
-- Shows what percentage of population got covid

Select location, date, total_cases, population,
CASE 
	When total_cases = 0 THEN 0
	Else CAST (total_cases as FLOAT) / population * 100 
	End as GotCovid
From PortfolioProject..CovidDeaths
Where location = 'France'
order by 1,2

-- Looking at countries with highest infection rate compared to population

SELECT 
    location, 
    MAX(CAST(total_cases AS DECIMAL(38, 0))) AS HighestInfectionCount, 
    population,
    MAX(CAST((CAST(total_cases AS DECIMAL(38, 10)) / NULLIF(CAST(population AS DECIMAL(38, 0)), 0)) * 100 AS DECIMAL(38, 10))) AS PercentPopulationInfected
FROM 
    PortfolioProject..CovidDeaths
GROUP BY 
    location, population
ORDER BY 
    PercentPopulationInfected DESC;
--Where location = 'France'

--Showing countries with highest death count per population.

SELECT 
    location, 
    MAX(Total_deaths) as TotalDeathcount
FROM 
    PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY 
    location
ORDER BY 
    TotalDeathcount DESC;

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

SELECT 
    location, 
    MAX(Total_deaths) as TotalDeathcount
FROM 
    PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY 
    location
ORDER BY 
    TotalDeathcount DESC;

-- GLOBAL NUMBERS

SELECT  
    SUM(new_cases) AS total_cases, 
    SUM(CAST(new_deaths AS INT)) AS total_deaths,
    CASE 
        WHEN SUM(new_cases) = 0 THEN 0
        ELSE (SUM(CAST(new_deaths AS FLOAT)) / SUM(CAST(new_cases AS FLOAT))) * 100 
    END AS DeathPercentage
FROM 
    PortfolioProject..CovidDeaths
WHERE 
    continent IS NOT NULL

-- Looking at total population vs vaccinations

-- USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (CAST(RollingPeopleVaccinated AS FLOAT) / CAST(population AS FLOAT)) * 100 AS VaccinationPercentage
FROM PopvsVac

-- TEMP TABLE

DROP TABLE if EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
SELECT *, (CAST(RollingPeopleVaccinated AS FLOAT) / CAST(population AS FLOAT)) * 100 AS VaccinationPercentage
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL



