/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

select *
from CovidDeaths
ORDER BY 3, 4

--select *
--from CovidVaccinations

SELECT location, DATE, total_cases, new_cases,total_deaths,population
FROM CovidDeaths
ORDER BY 1, 2

--LOOKING AT TOTAL CASES VS TOTAL DEATHS AS AT 30-04-2021
--Shows likelihood of dying if you contract covid in your country

SELECT location, DATE, total_cases,total_deaths,population,(total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
where location like '%nigeria%'
AND continent IS NOT NULL
ORDER BY 1, 2

--LOOKING AT TOTAL CASES VS POPULATION
--SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID

SELECT location, DATE, total_cases,population,(total_cases/population)*100 
AS PercentagePopulationInfected
FROM CovidDeaths
---where location like '%nigeria%'
ORDER BY 1, 2 

--LOOKING AT COUNTRIES WITH THE HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT location, population, MAX(total_cases) TotalCases, MAX((total_cases/population))*100 
AS PercentagePopulationInfected
FROM CovidDeaths
--where location like '%nigeria%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC

-- SHOWING COUNTRIES WITH THE HIGHEST DEATH COUNT COMPARED TO POPULATION

SELECT location, population, MAX(CAST(total_deaths AS INT)) TotalDeaths, MAX((total_deaths/population))*100 
AS PercentagePopulationDeath
FROM CovidDeaths
--where location like '%nigeria%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentagePopulationDeath desc


-- SHOWING COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION

SELECT location, MAX(CAST(total_deaths AS INT)) TotalDeathCount
FROM CovidDeaths
--where location like '%nigeria%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT
-- SHOWING CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION


SELECT continent, MAX(CAST(total_deaths AS INT)) TotalDeathCount
FROM CovidDeaths
--where location like '%nigeria%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

-- SHOWING CONTINENTS WITH THE HIGHEST DEATH COUNT COMPARED TO POPULATION

SELECT continent, MAX(CAST(total_deaths AS INT)) TotalDeaths, MAX((total_deaths/population))*100 
AS PercentagePopulationDeath
FROM CovidDeaths
--where location like '%nigeria%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY PercentagePopulationDeath desc


-- GLOBAL NUMBERS

SELECT  SUM (new_cases) AS TotalCases, 
SUM (CAST (new_deaths AS INT)) as TotalDeaths, 
SUM (CAST (new_deaths AS INT))/ SUM (new_cases)*100 as DeathPercentage
--,total_deaths,population,(total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
--where location like '%nigeria%'
where continent IS NOT NULL
--GROUP BY DATE
ORDER BY 1,2


-- LOOKING AT TOTAL POPULATION VS VACCINATIONS

select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM (CONVERT(INT, CV.new_vaccinations)) OVER (PARTITION BY CD.LOCATION ORDER BY CD.LOCATION, CD.DATE) AS RollingPeopleVaccinated
from CovidDeaths AS CD 
JOIN CovidVaccinations AS CV
	ON CD.location = CV.location
	AND CD.date = CV.date
	where CD.continent IS NOT NULL
	--WHERE CD.location like '%nigeria%'
	ORDER BY 1, 2, 3

--USE CTE

WITH PopVsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM (CONVERT(INT, CV.new_vaccinations)) OVER (PARTITION BY CD.LOCATION ORDER BY CD.LOCATION, CD.DATE) AS RollingPeopleVaccinated
from CovidDeaths AS CD 
JOIN CovidVaccinations AS CV
	ON CD.location = CV.location
	AND CD.date = CV.date
	where CD.continent IS NOT NULL
	--WHERE CD.location like '%nigeria%'
	--ORDER BY 1, 2, 3)
	)
	SELECT * , RollingPeopleVaccinated/population*100
	FROM PopVsVac
	
--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar (255),
Location nvarchar (255),
Date Datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)


INSERT INTO #PercentPopulationVaccinated
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM (CONVERT(INT, CV.new_vaccinations)) OVER (PARTITION BY CD.LOCATION ORDER BY CD.LOCATION, CD.DATE) AS RollingPeopleVaccinated
from CovidDeaths AS CD 
JOIN CovidVaccinations AS CV
	ON CD.location = CV.location
	AND CD.date = CV.date
	where CD.continent IS NOT NULL
	--WHERE CD.location like '%nigeria%'
	--ORDER BY 1, 2, 3)
	

	SELECT *,  RollingPeopleVaccinated/population*100 as RollingPeopleVaccinatedPercentage
	FROM #PercentPopulationVaccinated


--CREATING VIEWS TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated AS
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM (CONVERT(INT, CV.new_vaccinations)) OVER (PARTITION BY CD.LOCATION ORDER BY CD.LOCATION, CD.DATE) AS RollingPeopleVaccinated
from CovidDeaths AS CD 
JOIN CovidVaccinations AS CV
	ON CD.location = CV.location
	AND CD.date = CV.date
	where CD.continent IS NOT NULL
	--WHERE CD.location like '%nigeria%'
	--ORDER BY 1, 2, 3


SELECT * 
FROM PercentPopulationVaccinated

