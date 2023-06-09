

--Looking at Total Cases vs Total Deaths
Select location,date,total_cases,total_deaths,(convert(float,total_deaths)/convert(float,total_cases)) *100 as DeathPrecentage
From POrtfolioProject.dbo.CovidDeaths
Where location like '%Romania%'
and continent is not null
Order By 1,2

--Show when precentage of population got Covid
Select location,date,Population,total_cases,(convert(float,total_cases)/convert(float,population)) *100 as PrecentPopulationInfected
From POrtfolioProject.dbo.CovidDeaths
Where location like '%Romania%'
and continent is not null
Order By 1,2

--Looking at Countries with Highest Infection Rate
Select location,Population ,MAX(cast(total_cases as int)) as HighestInfectedCount, Max(total_cases/population) *100 as PrecentPopulationInfected
From POrtfolioProject.dbo.CovidDeaths
--Where location like '%Romania%'
Where continent is not null
Group by location,Population
Order By PrecentPopulationInfected desc


--Showing the countries with Highest Death Count per population
Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From POrtfolioProject.dbo.CovidDeaths
Where continent is not null 
Group by location
Order By  TotalDeathCount desc

--LELT'S BREAK THINGS DOWN BY CONTINENTS
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
Select date,SUM(cast(new_cases as int)) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPrecentage
From POrtfolioProject.dbo.CovidDeaths
--Where location like '%Romania%'
Where continent is not null 
and new_cases!='0'
Group by date
Order By 1,2
 
Select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPrecentage
From POrtfolioProject.dbo.CovidDeaths
--Where location like '%Romania%'
Where continent is not null 
--Group by date
Order By 1,2

--Looking at total Population vs Vaccination
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(BigInt,vac.new_vaccinations)) OVER (Partition by  dea.location Order by
dea.location,dea.date) as RollingPeopleVaccinated
From POrtfolioProject.dbo.CovidDeaths dea
Join POrtfolioProject.dbo.CovidVaccinations vac
	On dea.location=vac.location 
	and dea.date=vac.date
Where dea.continent is not null
--and dea.location like '%Romania%'
Order by 2,3

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(BigInt,vac.new_vaccinations)) OVER (Partition by  dea.location Order by dea.location,dea.date ) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From POrtfolioProject.dbo.CovidDeaths dea
Join POrtfolioProject.dbo.CovidVaccinations vac
	On dea.location=vac.location 
	and dea.date=vac.date
Where dea.continent is not null
--and dea.location like '%Romania%'
Order by 2,3



--USE CTE
With PopvsVAc (Continent, Location,Date,Population,New_Vaccination, RollingPeopleVaccinated)
as(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(BigInt,vac.new_vaccinations)) OVER (Partition by  dea.location Order by dea.location,dea.date ) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From POrtfolioProject.dbo.CovidDeaths dea
Join POrtfolioProject.dbo.CovidVaccinations vac
	On dea.location=vac.location 
	and dea.date=vac.date
Where dea.continent is not null
--and dea.location like '%Romania%'
--Order by 2,3
)




--Temp table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PrecentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PrecentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by  dea.location Order by dea.location,dea.date ) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From POrtfolioProject.dbo.CovidDeaths dea
Join POrtfolioProject.dbo.CovidVaccinations vac
	On dea.location=vac.location 
	and dea.date=vac.date
Where dea.continent is not null
--and dea.location like '%Romania%'
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PrecentPopulationVaccinated



--Creating View to store data for visualization
Drop view if exists PrecentPopulationVaccinated

Create View PrecentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by  dea.location Order by dea.location,dea.date ) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From POrtfolioProject.dbo.CovidDeaths dea
Join POrtfolioProject.dbo.CovidVaccinations vac
	On dea.location=vac.location 
	and dea.date=vac.date
Where dea.continent is not null
--and dea.location like '%Romania%'
--Order by 2,3


