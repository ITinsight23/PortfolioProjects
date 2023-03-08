/* First of all I created the tables "coviddeaths" and "covidvaccinations" in order to import the csv files. 
The columns are of a variety of 3 data types: VARCHAR, DECIMAL and BIGINT.
Bellow you can see that the 2 tables have been populated in the correct way. */

SELECT * FROM coviddeaths;

SELECT * FROM covidvaccinations;


/* First of all we select all the data that we're gonna be using */

SELECT location, date, total_cases, new_cases, total_deaths, population FROM coviddeaths
ORDER BY 1,2;


/* This shows the chance of dying if contracting the virus, but because the columns "total_deaths"
and "total_cases" are BIGINT types, the answer would be 0, so I had to convert them to DECIMAL. */

ALTER TABLE coviddeaths ALTER COLUMN total_cases TYPE DECIMAL;
ALTER TABLE coviddeaths ALTER COLUMN total_deaths TYPE DECIMAL;

SELECT location, date, total_cases,  total_deaths, ROUND((total_deaths/total_cases)*100,2) as death_percentage FROM coviddeaths
WHERE location = 'Romania' AND date > '2021-01-01'
ORDER BY 1,2;


/* Looking at the countries with the highest infection rate compared to the population */

SELECT location, population, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM coviddeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;


/* Looking at the countries with the highest death count per population */

SELECT location, MAX(total_deaths) as TotalDeathCount FROM coviddeaths
WHERE continent iS NOT NULL
GROUP BY location
HAVING MAX(total_deaths) IS NOT NULL
ORDER BY TotalDeathCount DESC;


/* Looking at the continents with the highest death count per population */

SELECT location, MAX(total_deaths) as TotalDeathCount FROM coviddeaths
WHERE continent iS NULL
GROUP BY location
HAVING MAX(total_deaths) IS NOT NULL
ORDER BY TotalDeathCount DESC;


/* Looking at the global numbers for the death cases and percentage in relation to the new cases */

SELECT date, SUM(new_cases) AS cases, SUM(new_deaths) as deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
HAVING SUM(new_cases) IS NOT NULL
ORDER BY 1,2;


/* Looking at total population in relation to total vaccinations */
/* Because I just created a column in this querry I have to use CTE */

WITH PopulationVaccination (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT d.continent, d.location, d.date, d.population, new_vaccinations, SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date)
AS RollingPeopleVaccinated
FROM CovidDeaths AS d
INNER JOIN CovidVaccinations AS v 
	ON d.location = v.location 
	AND d.date = v.date
WHERE d.continent IS NOT NULL
	)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentageVaccination FROM PopulationVaccination;


/* Creating view to store data for visualizations */
CREATE VIEW PercentageVaccinations AS
WITH PopulationVaccination (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT d.continent, d.location, d.date, d.population, new_vaccinations, SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date)
AS RollingPeopleVaccinated
FROM CovidDeaths AS d
INNER JOIN CovidVaccinations AS v 
	ON d.location = v.location 
	AND d.date = v.date
WHERE d.continent IS NOT NULL
	)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentageVaccination FROM PopulationVaccination;
