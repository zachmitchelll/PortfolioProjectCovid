

Select *
From PortfolioProjectCovid.dbo.CovidDeaths
Where continent is not NULL
Order by 3,4

--Select *
--From PortfolioProjectCovid.dbo.CovidVaccinations
--Order by 3,4


--Selecting the data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjectCovid.dbo.CovidDeaths
Order by 1,2


--Changed both total_cases and total_deaths to numeric

ALTER TABLE PortfolioProjectCovid.dbo.CovidDeaths ALTER COLUMN total_cases NUMERIC NULL
ALTER TABLE PortfolioProjectCovid.dbo.CovidDeaths ALTER COLUMN total_deaths NUMERIC NULL


--Looking at Total Cases vs the Total Deaths
--Shows the chance of dying from the contraction of covid at various time periods for the United States

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjectCovid.dbo.CovidDeaths
Where location = 'United States'
Order by 1,2


--Looking at Total Cases vs Population
--Shows the percentage of the United states population that contracted covid at various times

Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProjectCovid.dbo.CovidDeaths
--Where location = 'United States'
Order by 1,2


--Looking at Countries with the Highest Infection Rate compared to Population
--Shows the highest percentage of infected populations by country

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProjectCovid.dbo.CovidDeaths
--Where location = 'United States'
Group by location, population
Order by PercentPopulationInfected desc


--Shows Countries with Highest Death Count per Population

Select location, MAX(total_deaths) as TotalDeathCount
From PortfolioProjectCovid.dbo.CovidDeaths
--Where location = 'United States'
Where continent is not NULL
Group by location
Order by TotalDeathCount desc


--DIFFERENCES BETWEEN CONTINENTS

--Showing the continents with the hightest covid death counts

Select continent, MAX(total_deaths) as TotalDeathCount
From PortfolioProjectCovid.dbo.CovidDeaths
--Where location = 'United States'
Where continent is not NULL
Group by continent
Order by TotalDeathCount desc


--Global Numbers
--Showing the total cases, total deaths, and global death percentage

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProjectCovid.dbo.CovidDeaths
--Where location = 'United States'
where continent is not null 
order by 1,2


--Change new vaccinations column to numeric

ALTER TABLE PortfolioProjectCovid.dbo.CovidVaccinations ALTER COLUMN new_vaccinations NUMERIC NULL

--Total Population vs Vaccinations
--Showing the percentage of the population that has recieved at least one covid vaccine dose

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjectCovid.dbo.CovidDeaths dea
Join PortfolioProjectCovid.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


--Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjectCovid.dbo.CovidDeaths dea
Join PortfolioProjectCovid.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentVaccinated
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjectCovid.dbo.CovidDeaths dea
Join PortfolioProjectCovid.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100 as PercentVaccinated
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjectCovid.dbo.CovidDeaths dea
Join PortfolioProjectCovid.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
From PercentPopulationVaccinated