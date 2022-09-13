
select *
from PortfolioProject..covidDeaths
where continent is not null
order by 3,4


--select *
--from PortfolioProject..covidVaccination$
--order by 3,4

select Location, date, total_cases, new_cases,total_deaths, population
from PortfolioProject..covidDeaths
order by 1,2


--looking at total cases and total Deaths
--death percentage
select Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..covidDeaths
where location like '%states%'
order by 1,2

--looking as total cases vs population
--shows what percentage of population got covid
select Location, date,population, total_cases,(total_cases/population)*100 as  PercentPopulationInfected
from PortfolioProject..covidDeaths
where location like '%states%'
order by 1,2

--looking at countries with Highest Infection rate compared with population
select Location,population, MAX(total_cases) as HighestInfectionCount,Max((total_cases/population))*100 as percentpopulationInfected
from PortfolioProject..covidDeaths
--where location like '%states%'
group by Location, population
order by percentpopulationInfected desc

--showing the countries with Highest Death count per population
select Location ,MAX(cast(Total_deaths as int )) as totaldeathCount
from PortfolioProject..covidDeaths
--where location like '%states%'
where continent is not null
group by Location
order by totaldeathCount desc

--Break Things Down by Continent
--showing the continet with highest deathcount
select location ,MAX(cast(Total_deaths as int )) as totaldeathCount
from PortfolioProject..covidDeaths
--where location like '%states%'
where continent is  null
group by location
order by totaldeathCount desc

--Global Numbers

select SUM(new_cases) as totalCases,SUM(cast(new_deaths as int))as totaldeathcases,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as totalpercentage-- total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..covidDeaths
where continent is not null
order by 1,2


--looking as total population vs vaccinated
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS float)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeoplevaccinated
-- (RollingPeoplevaccinated/populations)*100

from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccination$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

--USE CTE
with PopvsVac (Continent,location, date,population,new_vaccinations,RollingPeoplevaccinated)
as
(
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS float)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeoplevaccinated
-- (RollingPeoplevaccinated/population)*100

from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccination$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
)
select * , (RollingPeoplevaccinated/population)*100
From PopvsVac


-- Temp Table

Drop Table if exists percentPopulationVaccinated
create table percentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)
Insert into percentPopulationVaccinated


select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS float)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeoplevaccinated
-- (RollingPeoplevaccinated/population)*100

from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccination$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null

select * , (RollingPeoplevaccinated/population)*100
From percentPopulationVaccinated


---creating view to store data for later visualization

create View percentPopulationVaccinate as
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS float)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeoplevaccinated
-- (RollingPeoplevaccinated/population)*100

from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccination$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null

select * from
percentPopulationVaccinate

