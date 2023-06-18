/*

Queries used for Tableau Project

*/

-- Query 1: Calculate total cases, total deaths, and death percentage
-- We exclude records where continent is not specified and order by total_cases and total_deaths

Select SUM(new_cases) as total_cases, 
       SUM(cast(new_deaths as int)) as total_deaths, 
       SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2


-- Query 2: Calculate total death count for each location
-- We exclude records where continent is null and the locations 'World', 'European Union', 'International'
-- Results are grouped by location and ordered by total death count

Select location, 
       SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- Query 3: Fetch the highest infection count and percentage of population infected for each location
-- Results are grouped by location and population and ordered by percentage of population infected

Select Location, 
       Population, 
       MAX(total_cases) as HighestInfectionCount,  
       Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- Query 4: Fetch the highest infection count and percentage of population infected for each location and date
-- Results are grouped by location, population, and date, and ordered by percentage of population infected

Select Location, 
       Population, 
       date, 
       MAX(total_cases) as HighestInfectionCount,  
       Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc
