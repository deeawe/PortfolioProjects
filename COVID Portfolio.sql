SELECT *
FROM PortfolioProject..Covid_Deaths

SELECT *
FROM PortfolioProject..Covid_Vaccinations
WHERE new_tests IS NULL
ORDER BY 3, 2

--Select Data that we would use in the project

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..Covid_Deaths
ORDER BY 1, 2

--Update tables by replacing 0 with NULL because NULL values were not imported

UPDATE PortfolioProject..Covid_Deaths
SET total_cases = NULL WHERE total_cases = 0

UPDATE PortfolioProject..Covid_Deaths
SET total_deaths = NULL WHERE total_deaths = 0

----Looking at the Total Cases vs Total Deaths
----Shows likelihood of dying when one gets covid per country.

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS Death_Percentage
FROM PortfolioProject..Covid_Deaths
WHERE location LIKE '%State%'
ORDER BY 1, 2


--Looking at the Total Cases vs Total deaths in Nigeria
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS Death_Percentage
FROM PortfolioProject..Covid_Deaths
WHERE location LIKE '%Nigeria%'
ORDER BY 1, 2

-- Looking at the Total Cases vs Population
--Shows what percentage of the population has covid
SELECT location, date, population, total_cases, (total_cases/population) * 100 AS Percentage_case_per_population
FROM PortfolioProject..Covid_Deaths
WHERE location LIKE '%Nigeria%' AND continent NOT IN (' ')
ORDER BY 1, 2


--Looking at countries with highest infection rate compared to the population
SELECT location, population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/NULLIF(population, 0)) * 100 ) AS Percent_Population_Infected
FROM PortfolioProject..Covid_Deaths
WHERE continent NOT IN (' ')
GROUP BY location, population
ORDER BY 4 DESC

--Showing Countries with the highest mortality count per population
SELECT Location, population, MAX(total_deaths) AS Highest_Death_Count
FROM PortfolioProject..Covid_Deaths
WHERE continent NOT IN (' ')
GROUP BY Location, population
ORDER BY 3 DESC

--Considering the continents
-- Showing continents with the highest death count
SELECT location, MAX(total_deaths) AS Highest_Death_Count
FROM PortfolioProject..Covid_Deaths
WHERE continent IN (' ')
GROUP BY location
ORDER BY 2 DESC

--Global numbers
--Death percentage per day for new cases
SELECT date, SUM(new_cases) AS total_new_cases, SUM(new_deaths) AS total_new_deaths, (SUM(new_deaths)/SUM(NULLIF(new_cases, 0)) * 100) AS Death_Percentage
FROM PortfolioProject..Covid_Deaths
WHERE continent IN (' ')
GROUP BY date
ORDER BY 4 DESC

--Total Death Percentage
SELECT SUM(new_cases) AS total_new_cases, SUM(new_deaths) AS total_new_deaths, (SUM(new_deaths)/SUM(NULLIF(new_cases, 0)) * 100) AS Death_Percentage
FROM PortfolioProject..Covid_Deaths
WHERE continent IN (' ')
--GROUP BY date
ORDER BY 3



--Looking at the total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_New_Vaccinations
FROM PortfolioProject..Covid_Deaths AS dea
	JOIN PortfolioProject..Covid_Vaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent NOT IN (' ')
ORDER BY 2, 3 

--USE CTE

WITH PopVac AS (SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
				SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_New_Vaccinations
						FROM PortfolioProject..Covid_Deaths AS dea
								JOIN PortfolioProject..Covid_Vaccinations AS vac
								ON dea.location = vac.location
								AND dea.date = vac.date
						WHERE dea.continent NOT IN (' ')
				)
SELECT *, (Rolling_New_Vaccinations/NULLIF(population, 0)) * 100 AS Rolling_Vaccination_Percentage
FROM PopVac


--USE TEMP TABLE

DROP TABLE IF EXISTS #Percent_Population_Vaccinated
CREATE TABLE #Percent_Population_Vaccinated
(
Continent NVARCHAR(255) NULL,
location NVARCHAR(255),
date DATETIME,
population NUMERIC,
New_Vaccinations NUMERIC,
Rolling_People_Vaccinated NUMERIC
)

Insert into #Percent_Population_Vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
				SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_New_Vaccinations
						FROM PortfolioProject..Covid_Deaths AS dea
								JOIN PortfolioProject..Covid_Vaccinations AS vac
								ON dea.location = vac.location
								AND dea.date = vac.date
						WHERE dea.continent NOT IN (' ')
SELECT *
FROM #Percent_Population_Vaccinated

--Creating View to Store data later to be visualized

CREATE VIEW Percent_Population_Vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_New_Vaccinations
FROM PortfolioProject..Covid_Deaths AS dea
	JOIN PortfolioProject..Covid_Vaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent NOT IN (' ')


DROP VIEW IF EXISTS Percent_Population_Vaccinated