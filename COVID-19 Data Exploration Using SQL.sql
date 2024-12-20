SELECT * FROM CovidDeaths
WHERE continent is not null;



--SELECT * FROM CovidVaccinations;

SELECT Location, date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths
order by 1,2;

--Total cases vs Total Deaths

SELECT Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
order by 1,2;

--estimates

SELECT Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
where location like '%india%'
order by 1,2;


--Total cases vs Population
--percentage got covid

SELECT Location,population, total_cases,(total_cases/population)*100 as cases_affected
FROM CovidDeaths
WHERE location like '%india%'
order by 1,2;


--Countries with highest infection rate

SELECT Location,population, MAX(total_cases) AS highest_infection_count,MAX((total_cases/population))*100 as Percentage_cases_affected
FROM CovidDeaths
group by location,population
order by Percentage_cases_affected DESC;


--showing countries with highest death percentage

SELECT Location, MAX(cast(total_deaths as int)) AS highest_death_count
FROM CovidDeaths
WHERE continent is not null
group by location
order by highest_death_count DESC;


--break things down by continent

SELECT location, MAX(cast(total_deaths as int)) AS highest_death_count
FROM CovidDeaths
WHERE continent is  null
group by location
order by highest_death_count DESC;

--showing continents with highest death counts

SELECT continent, MAX(cast(total_deaths as int)) AS highest_death_count
FROM CovidDeaths
WHERE continent is not  null
group by continent
order by highest_death_count DESC;

--global numbers  by date

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100  as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
group by date
order by 1,2;

--global numbers

SELECT  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100  as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
--group by date
order by 1,2;

--total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_people_vaccinated
--(Rolling_people_vaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
ON dea.location = vac.location 
and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3;


--USE CTE

With PopvsVac (continent,location,date,population,new_vaccinations,Rolling_people_vaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_people_vaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
ON dea.location = vac.location 
and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
SELECT *,(Rolling_people_vaccinated/population)*100
FROM PopvsVac




--TEMP TABLE
DROP table if exists #PercentagePopulationVaccinated
CREATE Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_people_vaccinated numeric
)
Insert into #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_people_vaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
ON dea.location = vac.location 
and dea.date = vac.date
--WHERE dea.continent is not null
--order by 2,3

SELECT *,(Rolling_people_vaccinated/population)*100
FROM #PercentagePopulationVaccinated



--VIEWS TO STORE DATA FOR VISUALIZTIONS

CREATE View PercentagePopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_people_vaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
ON dea.location = vac.location 
and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3


Select * From PercentagePopulationVaccinated
