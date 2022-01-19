select *
From PortfolioProjects..CovidDeaths
order by 3,4

select *
from PortfolioProjects..CovidVaccinations
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProjects..CovidDeaths
order by 1,2

--total cases vs total deaths in the United States
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProjects..CovidDeaths
where location like '%states%'
order by 1,2

--Total Cases against United States population
--what percentage of the population has contracted Covid
select location, date, population, total_cases, (total_cases/population)*100 as PositivePercentage
from PortfolioProjects..CovidDeaths
where location like '%states%'
order by 1,2

--Countries with the highest infection rate compared to population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProjects..CovidDeaths
--where location like '%haiti%'
group by location, population
order by PercentPopulationInfected desc

--Countries with the Highest Death Count per population
select location, population, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths
--where location like '%states%'
where continent is not null
group by location, population
order by TotalDeathCount desc

-- Showing contintents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

--previous query version 2
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths
Where continent is null 
and location not like '%income%'
Group by location
order by TotalDeathCount desc

--GLOBAL NUMBERS
select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as GlobalDeathPercentage
from PortfolioProjects..CovidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1

--looking at total population vs vaccination
--join example
--due to int limitations, filter by continent
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
    and dea.continent like '%north america%'
order by 2,3
