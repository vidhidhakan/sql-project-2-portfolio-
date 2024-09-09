
select *
from [portfolio project]..CovidDeaths
where continent is not null
order by 3,4



--select * 
--from [portfolio project]..Covidvaccinations
--order by 3,4


select location, date , total_cases, new_cases, total_deaths, population
from [portfolio project].dbo.CovidDeaths
where continent is not null
order by location asc

---- looking at total cases v/s total deaths 

select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from [portfolio project].dbo.CovidDeaths$
order by location asc

---- query 2
select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from [portfolio project].dbo.CovidDeaths$
where location = 'Afghanistan'
order by location asc

--- looking at total cases v/s total population
-- shows perecentage of poulation got covid

select location, date, total_cases,population,(total_cases/population)*100 as deathpercentage
from [portfolio project].dbo.CovidDeaths$
where location like '%states%'
order by location asc

---- looking at countries with highest total cases got infected compared to population

select location,date,population,max(total_cases)as highestinfectionrate ,max(total_cases/population)*100 as percentagepoulationinfected
from [portfolio project].dbo.CovidDeaths
group by location , date,population
order by percentagepoulationinfected desc

--- looking continents with highest death count per population 

-- convert varchar into int 0 by using cast 

select location,  max(cast(total_deaths as int)) as totaldeathcount
from [portfolio project].dbo.CovidDeaths
where continent is not null
group by location
order by totaldeathcount desc


select location,  max(cast(total_deaths as int)) as totaldeathcount
from [portfolio project].dbo.CovidDeaths
where continent is null
group by location
order by totaldeathcount desc



select * from [portfolio project].dbo.CovidDeaths 



------------- showing contint with highest death count per population 

select  continent, max(cast(total_deaths as int)) as totaldeathcount
from [portfolio project].dbo.CovidDeaths
where continent is not null 
group by continent
order by totaldeathcount desc



---------------- global numbers ----------------

select date, total_cases, total_deaths, (total_deaths/total_cases)*100 as totalpercentage
from [portfolio project].dbo.CovidDeaths
where continent is not null
order by 1, 2

select date, sum(new_cases)
from [portfolio project].dbo.CovidDeaths
where continent is not null
group by date
order by 1,2 

select  sum(new_cases)as totalcases, sum(cast(new_deaths as int))as totaldeaths
from [portfolio project].dbo.CovidDeaths
where continent is not null
order by 1,2 

----------------------------------------------------------------------

select * from [portfolio project].dbo.covidvaccinations

select * from [portfolio project].dbo.CovidDeaths

-- joins 

select * from [portfolio project].dbo.CovidDeaths as dea
join  [portfolio project].dbo.covidvaccinations as vac
on dea.location = vac.location  and dea.date = vac.date

-- looking at total population v/s vaccinations 


select dea.continent, dea.date, dea.population, dea.location, vac.new_vaccinations 
from [portfolio project].dbo.covidvaccinations as vac 
join [portfolio project].dbo.CovidDeaths as dea 
on dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null
order by 1,2,3



select dea.continent, dea.date, dea.population, dea.location, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingcount
from [portfolio project].dbo.covidvaccinations as vac 
join [portfolio project].dbo.CovidDeaths as dea 
on dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null
order by 1,2,3


-------------use cte 

with popvsvac (continent, location ,date ,population, new_vaccinations,rollingcount)
as
(select dea.continent, dea.date, dea.population, dea.location, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingcount
from [portfolio project].dbo.covidvaccinations as vac 
join [portfolio project].dbo.CovidDeaths as dea 
on dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null
)

select * from popvsvac


----- temp table 


DROP TABLE IF EXISTS #personvaccinated;

CREATE TABLE #personvaccinated (
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population int,
    new_vaccinations int,
    rollingcount int
);

INSERT INTO #personvaccinated (continent, location, date, population, new_vaccinations, rollingcount)
SELECT 
    dea.continent, 
    dea.location,  -- Corrected to select `location` second
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingcount
FROM 
    [portfolio project].dbo.covidvaccinations AS vac
JOIN 
    [portfolio project].dbo.CovidDeaths AS dea 
ON 
    dea.location = vac.location 
AND 
    dea.date = vac.date 
WHERE 
    dea.continent IS NOT NULL;

SELECT * FROM #personvaccinated;


--- create views

	
---- looking at countries with highest total cases got infected compared to population



create view vidhidhakan as 
SELECT 
    dea.continent, 
    dea.location,  -- Corrected to select `location` second
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingcount
FROM 
    [portfolio project].dbo.covidvaccinations AS vac
JOIN 
    [portfolio project].dbo.CovidDeaths AS dea 
ON 
    dea.location = vac.location 
AND 
    dea.date = vac.date 
WHERE 
    dea.continent IS NOT NULL;


select * from vidhidhakan


