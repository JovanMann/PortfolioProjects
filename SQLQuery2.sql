Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Select the appropriate data needed for analysis

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at the total cases versus total deaths. Do higher cases exactly mean more deaths. Does this indicate the living standards or general health?
-- Shows the likelihood of death if you contract Covid in the United Kingdom

Select Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%United Kingdom%'
order by 1,2

--Looking at the total cases vs Population
-- Shows what percentage of population got covid in the UK.

Select Location, date, Population, total_cases, (Total_cases/population)*100 as PecentagePopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%United Kingdom%'
order by 1,2

-- Looking at countries with highest infection rates compared to populations

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location,Population
order by PercentPopulationInfected desc

--Results-- We found from our data that Seychelles has the highest percentage of population infected however it has a relatively lower population compared to the USA that has a consideraly large population.

-- Showing the countries with the highest death count per population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc


-- Ananlyse using continent instead of country 
-- How do continents compare to each other.
-- Showing continents with the highest death count

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group by Location
order by TotalDeathCount desc



-- Global Numbers -- 

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage --total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%United Kingdom%'
where continent is not null
Group by date
order by 1,2

-- Across the whole global, total number of cases and deaths from the start to present

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage --total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%United Kingdom%'
where continent is not null
--Group by date
order by 1,2


-- Across the globe since the pandemic we can find that there has been a 2.06% death rate from those that contracted covid-19.

-- Introduce vaccinations and the impact it has on the number of cases and deaths. These deaths are researched to be findings of the direct impact of Covid-19 and not secondary illnesses. 
-- Looking at total population versus vaccinations. How many people in the world are fully vaccinated.



Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as CumulativeVaccinations
--, (CumulativeVaccinations/population)*100 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3



--CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, CumulativeVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as CumulativeVaccinations
--, (CumulativeVaccinations/population)*100 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select*, (CumulativeVaccinations/Population)*100
From PopvsVac



-- Temp Table

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CumulativeVaccinations numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as CumulativeVaccinations
--, (CumulativeVaccinations/population)*100 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select*, (CumulativeVaccinations/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualisations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as CumulativeVaccinations
--, (CumulativeVaccinations/population)*100 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

