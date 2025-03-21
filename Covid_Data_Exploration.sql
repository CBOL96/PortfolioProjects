#First we change the type of Date Column
SELECT date, STR_TO_DATE(date,'%m/%d/%Y') as converted_date
FROM covid_deaths;

UPDATE covid_deaths
SET date = STR_TO_DATE(date,'%m/%d/%Y');

ALTER TABLE covid_deaths
MODIFY COLUMN date date;

SELECT date, STR_TO_DATE(date,'%m/%d/%Y') as converted_date
FROM covid_vaccination;
UPDATE covid_vaccination
SET date = STR_TO_DATE(date,'%m/%d/%Y');

ALTER TABLE covid_vaccination
MODIFY COLUMN date date;

-- Order by Country and date to check with the csv
SELECT * FROM covid_deaths
ORDER BY 'location' asc;



SELECT location,date,total_cases,new_cases,total_deaths,population
FROM covid_deaths
ORDER BY 1,2;

-- Total cases vs total death
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS 'Death percentage'
FROM covid_deaths
WHERE location = 'Paraguay'
ORDER BY 1,2;

-- Total cases vs Population
SELECT location,date,total_cases, population,(total_cases/population)*100 AS 'Infected percentage'
FROM covid_deaths
WHERE location = 'Paraguay'
ORDER BY 1,2;

-- Countries with highest Infection Rate compared to Population
SELECT location,population,max(total_cases) AS HighestInfectionCount, max((total_cases/population)*100) AS 'Infected percentage'
FROM covid_deaths
GROUP BY location,population
ORDER BY 4 desc;

-- Countries with highest Death per Population
SELECT location,population,max(cast(total_deaths as unsigned)) AS Deaths, max(cast(total_deaths as unsigned)/population)*100 AS 'Death percentage'
FROM covid_deaths
WHERE continent !='' 
GROUP BY location,population
ORDER BY 4 desc;

-- Deaths by Continent
WITH MaxDeathsCountry AS (
    SELECT continent,location, MAX(cast(total_deaths as unsigned)) AS MaxDeaths
    FROM covid_deaths
    WHERE continent != ''
    GROUP BY continent,location
    ORDER BY MaxDeaths DESC
)
SELECT continent, SUM(MaxDeaths) AS DeathsByContinent
FROM MaxDeathsCountry
GROUP BY continent;

-- Global number
SELECT SUM(new_cases),SUM(new_deaths),(SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
FROM covid_deaths
WHERE continent != '';


SELECT * FROM covid_vaccination;

-- Total Population vs Vaccinations
-- Create a CTE
WITH PopvsVac AS (
	SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS SumOfVaccinations
	FROM covid_deaths as dea
	JOIN covid_vaccination as vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent ='Europe')
SELECT *,(SumOfVaccinations/Population)*100 as 'Vaccinated/Population' FROM PopvsVac
ORDER BY 1,2;

-- CREATE A VIEW OF Total Population vs Vaccinations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS SumOfVaccinations
FROM covid_deaths as dea
JOIN covid_vaccination as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent =''
ORDER BY 2,3;

