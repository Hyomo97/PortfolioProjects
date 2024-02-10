--Exploering data
select *
From Portfolioproject..['covid death']
order by 3,4

select *
From Portfolioproject..['Covid Vaccination$']
order by 3,4

--select *
--From Portfolioproject..['Covid Vaccination$']
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
From Portfolioproject..['covid death']
Order by 1,2

--looking at total cases vs total deaths
select location, date, total_cases,total_deaths,Round((cast(total_deaths as float)/cast(total_cases as float))*100,3) as DeathPercentageRate
From Portfolioproject..['covid death']
Where location like '%states%'
Order by 1,2

--infection rate
select location, population, max(total_cases) as Highestinfectioncount, max((total_cases/population))*100 as populationinfected
From Portfolioproject..['covid death']
Group by location, population
Order by populationinfected desc

select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
From Portfolioproject..['covid death']
WHERE continent is not Null
Group by location
order by TotalDeathCount desc

--what about breakdown into continent?

select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
From Portfolioproject..['covid death']
WHERE continent is not Null
Group by continent
order by TotalDeathCount desc

select date, sum(new_cases), SUM(CAST(new_deaths as int)) as Total_deaths, SUM(CAST(new_deaths as int))/SUM(CAST(new_cases as int))*100 as DeathPercentace
From Portfolioproject..['covid death']
WHERE continent is not Null
Group by date
order by 1,2


--Looking at total population vs vaccinations
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as bigint)) OVER(PARTITION BY dea.location order by dea.location, dea.date) as RollingNumvaccinated
,(RollingNumvaccinated/population)*100 --cannot use column name that I just created!
From Portfolioproject..['covid death'] as dea
	join Portfolioproject..['Covid Vaccination$'] as vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3


--CTE
WITH PopvsVac (continent,location,date,population,new_vaccinations,RollingNumvaccinated)
as
(
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as bigint)) OVER(PARTITION BY dea.location order by dea.location, dea.date) as RollingNumvaccinated
--,(RollingNumvaccinated/population)*100 --cannot use column name that I just created!
From Portfolioproject..['covid death'] as dea
	join Portfolioproject..['Covid Vaccination$'] as vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
select*,(RollingNumvaccinated/population)*100 as infectionRate
From PopvsVac

--or Using Temp Table
Drop TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as bigint)) OVER(PARTITION BY dea.location order by dea.location, 
	dea.date) as RollingPeopleVaccinated
From Portfolioproject..['covid death'] as dea
join Portfolioproject..['Covid Vaccination$'] as vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

select*,(RollingPeopleVaccinated/population)*100 as infectionRate
From #PercentPopulationVaccinated

--creating view to store data for later visualization
create VIEW PercentPopulationVaccinated as
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as bigint)) OVER(PARTITION BY dea.location order by dea.location, 
	dea.date) as RollingPeopleVaccinated
From Portfolioproject..['covid death'] as dea
join Portfolioproject..['Covid Vaccination$'] as vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

select*
FROM PercentPopulationVaccinated