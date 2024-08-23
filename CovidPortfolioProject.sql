Select *
From PortfolioProject.coviddeaths
Where continent != ''
Order by 3,4 ;

/*
Select *
From PortfolioProject.covidvaccinations
Order by 3,4 ;
*/


-- Select data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.coviddeaths
Where continent != ''
Order by 1,2;


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in US
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.coviddeaths
Where location like '%states'
And continent != ''
Order by 1,2;


-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid 
Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject.coviddeaths
Where location like '%states'
And continent != ''
Order by 1,2;


-- Looking at Countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.coviddeaths
Where continent != ''
Group by location, population
Order by PercentPopulationInfected DESC;


-- Let's break things down by continent
Select continent, MAX(Total_deaths) as TotalDeathCount
From PortfolioProject.coviddeaths
Where continent != ''
Group by continent
Order by TotalDeathCount DESC;


-- Showing Countries with Highest Death Count per Population
Select location, MAX(Total_deaths) as TotalDeathCount
From PortfolioProject.coviddeaths
Where continent != ''
Group by location
Order by TotalDeathCount DESC;


-- Global Numbers
Select SUM(new_cases) as total_cases, SUM(new_deaths) as toal_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject.coviddeaths
WHERE continent != '' OR continent is not null
Order by 1,2;


-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent != ''
ORDER BY 2,3;


-- USE CTE
With PopvsVac (Continent, Locaiton, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent != ''
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac;


-- TEMP TABLE
USE PortfolioProject;
DROP TEMPORARY TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
	Continent VARCHAR(255),
    Location VARCHAR(255),
    Date DATETIME,
    Population DECIMAL(20, 2),
    New_vaccinations DECIMAL(20, 2),
    RollingPeopleVaccinated DECIMAL(20, 2)
);
INSERT INTO PercentPopulationVaccinated (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
SELECT dea.continent, dea.location, dea.date, dea.population, 
       NULLIF(vac.new_vaccinations, '') AS New_vaccinations, 
       SUM(NULLIF(vac.new_vaccinations, '')) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent != '';

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PercentPopulationVaccinated;


-- Create view to store data for later visualization
CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, 
       NULLIF(vac.new_vaccinations, '') AS New_vaccinations, 
       SUM(NULLIF(vac.new_vaccinations, '')) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent != '';

SELECT *
FROM PercentPopulationVaccinated;