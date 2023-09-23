-- UPDATING THE TABLE--
UPDATE covid_deaths 
SET continent = NULL 
WHERE continent = ''

UPDATE covid_vaccination  
SET continent = NULL 
WHERE continent = ''

SELECT * FROM covid_vaccination cv


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths cd 
ORDER BY 1,2


-- Looking at Total cases vs total deaths in Norway --

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM covid_deaths cd 
WHERE location = 'Norway'
ORDER BY 1,2

-- Looking at Total cases vs Population in Norway --

SELECT location, date, total_cases, population , (total_cases/population)*100 AS infected_percentage
FROM covid_deaths cd 
WHERE location = 'Norway'
ORDER BY 1,2

-- looking at countries with highest infection rate compared to population--

SELECT location, MAX(total_cases) AS highest_infection_count, population , MAX((total_cases/population))*100 AS infected_percentage
FROM covid_deaths cd
GROUP BY location , population 
ORDER BY infected_percentage DESC 

-- looking at the countries with the highest death count compared to population--

SELECT location, MAX(total_deaths) AS highest_death_count, population, (MAX(total_deaths) / population) * 100 AS death_percentage
FROM covid_deaths cd
WHERE continent is not NULL 
GROUP BY location, population 
ORDER BY highest_death_count DESC 

-- breaking things down by continent with highest death count--

SELECT location  , MAX(total_deaths) AS highest_death_count
FROM covid_deaths cd
WHERE continent is NULL AND location NOT LIKE '%income%' AND  location NOT LIKE "%Union%"
GROUP BY location 
ORDER BY highest_death_count DESC 

SELECT continent, MAX(total_deaths) AS highest_death_count
FROM covid_deaths cd
WHERE continent is not NULL 
GROUP BY continent 
ORDER BY highest_death_count DESC 

-- GLOBAL NUMBERS--

SELECT `date` ,SUM(new_cases) AS cases_per_day, SUM(new_deaths) AS deaths_per_day, SUM(new_deaths)/SUM(new_cases)*100 as death_percentage_per_day
FROM covid_deaths cd 
WHERE continent IS NOT NULL
GROUP BY `date` 
ORDER BY 1


-- joining both datasets or tables to show population and vaccination-- 

SELECT cd.continent , cd.location , cd.`date` , cd.population , cv.new_vaccinations,SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.`date`) AS rolling_vaccinated_people -- cumulative sum --
FROM covid_deaths cd
JOIN covid_vaccination cv 
ON cd.location = cv.location AND cd.`date` = cv.`date` 
WHERE cd.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE --

WITH PopvsVac (continent, location, date, population, new_vaccinations, rollingvaccinatedpeople)
AS 
(
SELECT cd.continent , cd.location , cd.`date` , cd.population , cv.new_vaccinations,SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.`date`) AS rollingvaccinatedpeople -- cumulative sum --
FROM covid_deaths cd
JOIN covid_vaccination cv 
ON cd.location = cv.location AND cd.`date` = cv.`date` 
WHERE cd.continent IS NOT NULL
)
SELECT *, (rollingvaccinatedpeople/population)*100
FROM PopvsVac

-- Creating view to store data for visualization--

CREATE VIEW percentvaccinatedpopulation AS
SELECT cd.continent , cd.location , cd.`date` , cd.population , cv.new_vaccinations,SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.`date`) AS rolling_vaccinated_people -- cumulative sum --
FROM covid_deaths cd
JOIN covid_vaccination cv 
ON cd.location = cv.location AND cd.`date` = cv.`date` 
WHERE cd.continent IS NOT NULL
ORDER BY 2,3
