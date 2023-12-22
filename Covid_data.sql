--Covid 19 Data Exploration 

--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types



--Selecting data starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM `arched-sorter-403020.Covid.Data`
WHERE continent is not null
ORDER BY 1,2


--Death percentage

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM `arched-sorter-403020.Covid.Data`
WHERE continent is not null
ORDER BY 1,2


--Death percentage for a particular country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM `arched-sorter-403020.Covid.Data`
where location like 'China' AND continent is not null
ORDER BY 1,2


--Percentage of population infected

SELECT location, date, total_cases, population, (total_cases/population)*100 as population_infected
FROM `arched-sorter-403020.Covid.Data`
where location like 'India'
ORDER BY 1,2


--Highest infection rate compared to population

SELECT location, population, MAX(total_cases) as max_cases, MAX((total_cases/population))*100 as max_population_infected
FROM `arched-sorter-403020.Covid.Data`
WHERE continent is not null
GROUP BY location, population
ORDER BY max_population_infected desc


--Countries with highest death count per population

SELECT location, MAX(cast(total_deaths as INT)) as max_death_count
FROM `arched-sorter-403020.Covid.Data`
WHERE continent is not null
GROUP BY location
ORDER BY max_death_count desc


--Continents with highest death count per population

SELECT location, MAX(cast(total_deaths as INT)) as max_death_count
FROM `arched-sorter-403020.Covid.Data`
WHERE continent is null
GROUP BY location
ORDER BY max_death_count desc


--Global numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as INT)) as total_deaths, SUM(cast(new_deaths as INT))/SUM(new_cases)*100 as death_percentage
FROM `arched-sorter-403020.Covid.Data`
where continent is not null
ORDER BY 1,2


--Total population vs vaccinations

SELECT continent, location, date, population, new_vaccinations, SUM(CAST(new_vaccinations as INT)) OVER (PARTITION BY location ORDER BY location, date) as vaccination_added_per_day
FROM `arched-sorter-403020.Covid.Data`
where continent is not null
ORDER BY 2,3

--Using CTE

WITH pop_vs_vac 
as
(
SELECT continent, location, date, population, new_vaccinations, SUM(CAST(new_vaccinations as INT)) OVER (PARTITION BY location ORDER BY location, date) as vaccination_added_per_day
FROM `arched-sorter-403020.Covid.Data`
where continent is not null
)
SELECT *, (vaccination_added_per_day/population)*100
FROM pop_vs_vac


--TEMP Table

DROP TABLE IF EXISTS Covid.percent_population_vaccinated
CREATE TABLE Covid.percent_population_vaccinated
(
continent STRING,
location STRING,
date datetime,
population INT,
vaccination_added_per_day INTEGER
)
INSERT INTO Covid.percent_population_vaccinated
SELECT continent, location, date, population, new_vaccinations, SUM(CAST(new_vaccinations as INT)) OVER (PARTITION BY location ORDER BY location, date) as vaccination_added_per_day
FROM `arched-sorter-403020.Covid.Data`
where continent is not null

SELECT *, (vaccination_added_per_day/population)*100
FROM Covid.percent_population_vaccinated


--Creating view to store data for visualization

CREATE VIEW Covid.percent_population_vaccinated as
SELECT continent, location, date, population, new_vaccinations, SUM(CAST(new_vaccinations as INT)) OVER (PARTITION BY location ORDER BY location, date) as vaccination_added_per_day
FROM `arched-sorter-403020.Covid.Data`
where continent is not null

SELECT*
FROM Covid.percent_population_vaccinated