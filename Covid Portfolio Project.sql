--EXPLORING the tables that will be used during the exploratory analysis

SELECT TOP 5* 
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 3,4;


SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

SELECT Location, Date, total_cases, total_deaths, 
       (COALESCE(total_deaths, 0) / NULLIF(total_cases, 0)) * 100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like 'Ukraine'
ORDER BY 1, 2;

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

SELECT Location, Date, population, total_cases,
       (COALESCE(total_cases, 0) / NULLIF(population, 0)) * 100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like 'Ukraine'
ORDER BY 1, 2;

--Looking at countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,
       (COALESCE(MAX(total_cases), 0) / NULLIF(population, 0)) * 100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC;

--Showing Countries with Highest Death Count Per Population

SELECT Location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount 
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, Population
ORDER BY TotalDeathCount DESC;


--Now we can change the perspective and look at the situation from the continents.

--Showing continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount 
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--Global Numbers 

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like 'Ukraine'
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2;


-- Looking at Total Population vs Vaccinations 
WITH PopvsVac(Continent,Location,Date,Population,New_Vaccinations,RollingpeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location and
	dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated (
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location and
	dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--CREATING VIEW to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, 
       dea.location, 
       dea.date, 
       dea.population, 
       vac.new_vaccinations, 
       SUM(CONVERT(INT, vac.new_vaccinations)) 
           OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
    ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *
FROM PercentPopulationVaccinated 

