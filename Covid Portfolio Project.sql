select * from PortfolioProject..CovidVaccinations$
where continent is not null

-- Select Data That we are going to be using 

select Location,date,total_cases,new_cases,total_deaths,population 
from PortfolioProject..CovidDeaths$
where continent is not null

-- Looking at Total Cases vs Total Deaths
-- Shows Likelyhood of dying
select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$ 
Where location like '%states%'


--Looking at Totalcases vs population in US
-- Shows what Population got Covid
select Location,date,total_cases,population,(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$ 
Where location like '%states%'


-- Looking at Countries with highest infection rate compared to population

select Location,population,MAX(total_cases) as HighestInfectionCount,Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$ 
group by Location,population
order by PercentPopulationInfected desc



-- Showing Countries with Higest DeathCounts per Population 

select Location,Max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths$ 
where continent is not null
group by Location
order by HighestDeathCount desc

-- By Countries


-- Showing the continent with the highest Deathcount 
select Location,Max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths$ 
where continent is not null
group by Location
order by HighestDeathCount desc

-- GLOBAL NUMBERS  


select sum(new_cases) as Total_new_cases,sum(cast(new_deaths as int)) as Tota_newdeaths,Sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$ 
--Where location like '%states%'
where continent is not null
--Group by date


-- Vaccination 

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
,sum(cast(vac.new_vaccinations as int)) over (Partition by  dea.location  order by dea.location, dea.date) as RollingPeopleVacinated

from PortfolioProject..CovidDeaths$ dea 
join PortfolioProject..CovidVaccinations$ vac 
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- USING CTE 

With PopsVsVac (Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as (
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
,sum(cast(vac.new_vaccinations as int)) over (Partition by  dea.location  order by dea.location, dea.date) as RollingPeopleVacinated
from PortfolioProject..CovidDeaths$ dea 
join PortfolioProject..CovidVaccinations$ vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select * ,(RollingPeopleVaccinated/Population)*100
from PopsVsVac



--Temp Table



create Table NoofPercentPopulationVaccinated 
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vacination numeric,
RollingPeopleVaccinated numeric
) 


insert into NoofPercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
,sum(cast(vac.new_vaccinations as int)) over (Partition by  dea.location  order by dea.location, dea.date) as RollingPeopleVacinated
from PortfolioProject..CovidDeaths$ dea 
join PortfolioProject..CovidVaccinations$ vac 
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 

Select *,(RollingPeopleVaccinated/Population)*100 
From NoofPercentPopulationVaccinated


-- Creating View to store data for later Visualization 

Create View  totPercentPopulationVaccinated as

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
,sum(cast(vac.new_vaccinations as int)) over (Partition by  dea.location  order by dea.location, dea.date) as RollingPeopleVacinated
from PortfolioProject..CovidDeaths$ dea 
join PortfolioProject..CovidVaccinations$ vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select * from totPercentPopulationVaccinated
