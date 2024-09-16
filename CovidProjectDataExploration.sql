select * from sqlportfofio.covidvaccination
order by 3,4;

select * from sqlportfofio.deathdata
order by 3,4;

-- select data we are going to using
select location, date, total_cases, new_cases, total_deaths, population
 from sqlportfofio.deathdata
 order by 1, 2;
 
 -- looking at total cases vs Total Deaths
 select location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
  from sqlportfofio.deathdata
  where location like '%United States'
 order by 1, 2;
 
 -- looking at Total Cases vs Population
 -- shows what percentage of pupulation got Covid
  select location, date, Population, total_cases, total_deaths,  (total_cases/population)* 100 as DeathPercentage
  from sqlportfofio.deathdata
  where location like '%africa'
 order by 1, 2;
 
 -- looking at Countries with highest infection compared to population
 select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))* 100 as PercenPopulationInfected
 from sqlportfofio.deathdata
 group by location, population
 order by PercenPopulationInfected desc;
 
 -- Showing Countries with highest Death count per Population
 select location, max(total_deaths) as TotalDeathCount
 from sqlportfofio.deathdata
 where location like '%Belgium'
 group by location
 order by TotalDeathCount desc;
 
 SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM sqlportfofio.deathdata
WHERE location IN ('Belgium', 'France', 'Africa', 'United States')
GROUP BY location
ORDER BY TotalDeathCount DESC;


select * from sqlportfofio.deathdata
where continent is not null
order by 3,4;
 
 select location, max(cast(total_deaths as signed)) as TotalDeathCount
 from sqlportfofio.deathdata
 where continent is not null
 group by location
 order by TotalDeathCount desc;
 
 -- let's break thinh down by continent
  select continent, max(cast(total_deaths as signed)) as TotalDeathCount
 from sqlportfofio.deathdata
 where continent is not null
 group by continent
 order by TotalDeathCount desc;
 
 -- Global mumbers
 select date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
 from sqlportfofio.deathdata
 where continent is not null
 order by 1,2;
 
 -- calculated the sum of new cases and new deaths by date, as well as the percentage of deaths in relation to new cases.
 select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as signed)) asTotalDeath, sum(cast(new_deaths as signed))/sum(new_cases)*100 as  DeathPercentage
 from sqlportfofio.deathdata
 where continent is not null
 group by date
 order by 1,2; 
 
 -- performs a join between two tables (deathdata and covidvaccination) on the location and date columns
 select*
 from sqlportfofio.deathdata dea
 join sqlportfofio.covidvaccination vac
 on dea.location = vac.location
 and dea.date = vac.date;
 
 -- Looking at Total Population vs Vaccination
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 from sqlportfofio.deathdata dea
 join sqlportfofio.covidvaccination vac
     on dea.location = vac.location
     and dea.date = vac.date
 where dea.continent is not null
 order by 2, 3;
 
  select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as signed)) over (partition by dea.location) as TotalVaccination
 from sqlportfofio.deathdata dea
 join sqlportfofio.covidvaccination vac
     on dea.location = vac.location
     and dea.date = vac.date
 where dea.continent is not null
 order by 2, 3;
 
 
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 sum(cast(vac.new_vaccinations as signed)) over (partition by dea.location order by dea.location, dea.date) as TotalVaccination
 from sqlportfofio.deathdata dea
 join sqlportfofio.covidvaccination vac
     on dea.location = vac.location
     and dea.date = vac.date
 where dea.continent is not null
 order by 2, 3;
 
 -- Temp Table
--
create table PercentPopulationVaccinated (
  Continent varchar(255),
  Location varchar(255),
  Date datetime,
  Population numeric,
  New_vaccinations numeric,
  RollingPeopleVaccinated numeric
);

-- insert Data in the new Table
insert into PercentPopulationVaccinated
select dea.continent, dea.location, str_to_date(dea.date, '%d/%m/%Y') as date, dea.population, vac.new_vaccinations, 
       sum(cast(vac.new_vaccinations as signed)) over (partition by dea.location order by dea.date) as RollingPeopleVaccinated
from sqlportfofio.deathdata dea
join sqlportfofio.covidvaccination vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
and vac.new_vaccinations != ''
  and vac.new_vaccinations is not null;

-- sélection des données avec le pourcentage de population vaccinée
select *, (RollingPeopleVaccinated / Population) * 100 as PercentPopulationVaccinated
from PercentPopulationVaccinated;

-- Creating View to store data for later visualisation
create view PercentPopulationVaccin as
select dea.continent, dea.location, str_to_date(dea.date, '%d/%m/%Y') as date, dea.population, vac.new_vaccinations, 
       sum(cast(vac.new_vaccinations as signed)) over (partition by dea.location order by dea.date) as RollingPeopleVaccinated
from sqlportfofio.deathdata dea
join sqlportfofio.covidvaccination vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
and vac.new_vaccinations != ''
  and vac.new_vaccinations is not null;