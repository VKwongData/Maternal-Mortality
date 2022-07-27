/*
This project explores data from OurWorldInData.org relating to maternal mortality, which is the risk that a woman dies from pregnancy-related causes.

We will use the following four tables to explore this data:
1) MaternalDeaths - the number of women who die from pregnancy-related causes 
2) MaternalMortalityRatio - the number of women who die from pregnancy-related causes while pregnant or within 42 days of pregnancy termination per 100,000 live births
3) LifetimeRiskMaternalDeath - the probability that a 15-year-old girl dies eventually from a pregnancy-related cause assuming that the number of children per woman and the maternal mortality rate remain at their current levels
4) RegionCodes - contains ISO country codes and which continent each country is located in

The tables split the data by country, region, income bracket, and year (2000-2017 for years available).

Additionally, we have the following table to add further insights into the data:
1) COVIDDeaths: COVID-related deaths to contrast how well a country handled COVID compared to maternal health

Sources: 
1) Ritchie, H., Mathieu, E., Rodés-Guirao, L., Appel, C., Giattino, C., Ortiz-Ospina, E., Hasell, J., Macdonald, B., Beltekian, D. & Roser, M. (2020). Coronavirus Pandemic (COVID-19) [Online resource]. OurWorldInData.org. https://ourworldindata.org/coronavirus
2) Roser, M. & Ritchie, H. (2013). Maternal Mortality [Online resource]. OurWorldInData.org. https://ourworldindata.org/maternal-mortality

Inspiration: Freberg, A. [AlexTheAnalyst]. (2021, May 4). Data Analyst Portfolio Project | SQL Data Exploration | Project 1/4 [Video]. YouTube. https://www.youtube.com/watch?v=_AMrJRQDPjk&t=148s
*/


-- Explore each table
SELECT TOP 1000 *
FROM PortfolioProject..MaternalDeaths
ORDER BY entity, year

SELECT TOP 1000 *
FROM PortfolioProject..LifetimeRiskMaternalDeath
ORDER BY entity, year

SELECT TOP 1000 *
FROM PortfolioProject..MaternalMortalityRatio
ORDER BY entity, year

SELECT *
FROM PortfolioProject..RegionCodes
ORDER BY location

SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY location, date


-- Do Inner Join to join the four maternal death tables
-- Select attributes that will be explored
SELECT continent, md.entity, md.year, number_of_maternal_deaths, lifetime_risk_of_maternal_death, maternal_mortality_ratio, population
FROM PortfolioProject..MaternalDeaths AS md
INNER JOIN PortfolioProject..LifetimeRiskMaternalDeath AS lr
	ON md.entity = lr.entity
	AND md.year = lr.year
INNER JOIN PortfolioProject..MaternalMortalityRatio AS mr
	ON md.entity=mr.entity
	AND md.year = mr.year
LEFT JOIN PortfolioProject..RegionCodes AS rc
	ON md.code = rc.iso_code
ORDER BY md.entity, md.year

-- Number of maternal deaths compared to total population per 100,000 people in 2017 by continent
SELECT continent, SUM(CAST (number_of_maternal_deaths AS double precision)) AS number_of_maternal_deaths, SUM(CAST (population AS double precision)) AS population, SUM(CAST(number_of_maternal_deaths AS double precision))/NULLIF(SUM(CAST(population AS double precision)),0)*100000 AS maternal_death_per_100000
FROM PortfolioProject..MaternalDeaths AS md
INNER JOIN PortfolioProject..MaternalMortalityRatio AS mr
	ON md.entity=mr.entity
	AND md.year = mr.year
LEFT JOIN PortfolioProject..RegionCodes AS rc
	ON mr.code = rc.iso_code
WHERE mr.year = 2017
-- Excluding region and income bracket data
	AND continent IS NOT NULL 
	AND continent !=''
GROUP BY continent
ORDER BY maternal_death_per_100000 DESC


-- Number of maternal deaths compared to total population per 100,000 people in 2017 by country
SELECT continent, md.entity AS country, md.year, number_of_maternal_deaths, population, CAST(number_of_maternal_deaths AS double precision)/NULLIF(CAST(population AS double precision),0)*100000 AS maternal_death_per_100000
FROM PortfolioProject..MaternalDeaths AS md
INNER JOIN PortfolioProject..MaternalMortalityRatio AS mr
	ON md.entity=mr.entity
	AND md.year = mr.year
LEFT JOIN PortfolioProject..RegionCodes AS rc
	ON md.code = rc.iso_code
WHERE md.year = 2017
-- Excluding region and income bracket data
	AND continent IS NOT NULL 
	AND continent !=''
ORDER BY maternal_death_per_100000 DESC


-- Country with highest lifetime risk of maternal death in 2017 by continent
SELECT rc.continent, lr.entity AS country, lifetime_risk_of_maternal_death AS percentage_of_women_expected_to_die
FROM PortfolioProject..LifetimeRiskMaternalDeath AS lr
LEFT JOIN PortfolioProject..RegionCodes AS rc
	ON lr.code = rc.iso_code
INNER JOIN 
	(
	SELECT continent, MAX(CAST(lifetime_risk_of_maternal_death AS double precision)) AS max_risk
	FROM PortfolioProject..LifetimeRiskMaternalDeath AS lr
	LEFT JOIN PortfolioProject..RegionCodes
		ON lr.code = RegionCodes.iso_code
	WHERE lr.year = 2017
	-- Excluding region and income bracket data
		AND continent IS NOT NULL 
		AND continent !=''
		GROUP BY continent
		) AS max_table
		ON lifetime_risk_of_maternal_death = max_table.max_risk
WHERE lr.year = 2017
ORDER BY percentage_of_women_expected_to_die DESC


-- Number of maternal deaths in 2017 compared to number of COVID deaths in 2021, relative to total populations in their respective years
-- Using Create Table, Temp Table, CTE, Alter Table, and View

-- Create new table to house data named Maternal_COVID_Death_Comparison
DROP TABLE IF EXISTS Maternal_COVID_Death_Comparison
CREATE TABLE Maternal_COVID_Death_Comparison
(
	continent nvarchar(255),
	country nvarchar(255), 
	code nvarchar(255), 
	maternal_deaths_2017 double precision,
	population_2017 double precision, 
	COVID_deaths_2021 double precision, 
	population_2021 double precision, 
	maternal_death_per_100000_2017 double precision, 
	COVID_death_per_100000_2021 double precision
)


-- Temp Table to calculate number of COVID deaths per 100,000 people for 2021 per country
DROP TABLE IF EXISTS #CovidDeathInfo
CREATE TABLE #CovidDeathInfo
(
iso_code nvarchar(255),
COVID_deaths_2021 double precision,
population_2021 double precision
)

INSERT INTO #CovidDeathInfo
SELECT iso_code,
	SUM(CAST(new_deaths AS double precision)) AS COVID_deaths_2021, 
	AVG(CAST(population AS double precision)) AS population_2021
FROM PortfolioProject..CovidDeaths
WHERE YEAR(CAST(date AS date)) = 2021
GROUP BY iso_code, YEAR(CAST(date AS date))


-- Explore Temp Table
SELECT TOP 1000 *
FROM #CovidDeathInfo


-- CTE to calculate number of maternal deaths per 100,000 people for 2017 per country
WITH MaternalDeathRate (continent, code, country, year, maternal_deaths_2017, population_2017, maternal_death_per_100000_2017)
AS
(
SELECT continent, 
	md.code, 
	md.entity AS country, 
	md.year, 
	number_of_maternal_deaths AS maternal_deaths_2017, 
	population AS population_2017, 
	CAST(number_of_maternal_deaths AS double precision)/NULLIF(CAST(population AS double precision),0)*100000 AS maternal_death_per_100000_2017
FROM PortfolioProject..MaternalDeaths AS md
INNER JOIN PortfolioProject..MaternalMortalityRatio AS mr
	ON md.code=mr.code
	AND md.year = mr.year
LEFT JOIN PortfolioProject..RegionCodes AS rc
	ON md.code = rc.iso_code
WHERE md.year = 2017
-- Excluding region and income bracket data
	AND continent IS NOT NULL 
	AND continent !=''
)


-- Insert data from joining CTE and temp table into Maternal_COVID_Death_Comparison table
INSERT INTO Maternal_COVID_Death_Comparison
SELECT md.continent,
	md.country, 
	md.code, 
	maternal_deaths_2017,
	population_2017, 
	COVID_deaths_2021, 
	population_2021, 
	maternal_death_per_100000_2017, 
	CAST(cd.COVID_deaths_2021 AS double precision)/NULLIF(CAST(population_2021 AS double precision),0)*100000 AS COVID_death_per_100000_2021
FROM MaternalDeathRate AS md
INNER JOIN #CovidDeathInfo AS cd
	ON md.code = cd.iso_code
ORDER BY md.country


-- Explore data in Maternal_COVID_Death_Comparison
SELECT *
FROM PortfolioProject..Maternal_COVID_Death_Comparison


-- How many times more than the average maternal deaths per 100,000 by continent is the number of maternal deaths per 100,000 by country in 2017?
SELECT continent, country, maternal_death_per_100000_2017, COVID_death_per_100000_2021, maternal_death_per_100000_2017/NULLIF(AVG(maternal_death_per_100000_2017) OVER(PARTITION BY continent),0) AS how_many_times_more_than_avg_maternal_death_per_100000_for_continent, COVID_death_per_100000_2021/NULLIF(AVG(COVID_death_per_100000_2021) OVER(PARTITION BY continent),0) AS how_many_times_more_than_avg_covid_death_per_100000_for_continent
FROM Maternal_COVID_Death_Comparison
ORDER BY continent, country 


-- For easier comparison, normalize maternal and covid deaths per 100,000 by country in 2017 and 2021, respectively

-- Update Maternal_COVID_Death_Comparison with new columns
ALTER TABLE Maternal_COVID_Death_Comparison

ADD normalized_maternal double precision,
	normalized_covid double precision


-- Declare the variables
declare @minmaternal as double precision
declare @maxmaternal as double precision
declare @mincovid as double precision
declare @maxcovid as double precision


-- Set variables
set @minmaternal = (select min(maternal_death_per_100000_2017) from Maternal_COVID_Death_Comparison)
set @maxmaternal = (select max(maternal_death_per_100000_2017) from Maternal_COVID_Death_Comparison)
set @mincovid = (select min(COVID_death_per_100000_2021) from Maternal_COVID_Death_Comparison)
set @maxcovid = (select max(COVID_death_per_100000_2021) from Maternal_COVID_Death_Comparison)


-- Update columns with normalized numbers
UPDATE Maternal_COVID_Death_Comparison
SET normalized_maternal = (maternal_death_per_100000_2017 - @minmaternal)/(@maxmaternal - @minmaternal)

UPDATE Maternal_COVID_Death_Comparison
SET normalized_covid = (COVID_death_per_100000_2021 - @mincovid)/(@maxcovid - @mincovid)


-- Explore data in updated Maternal_COVID_Death_Comparison table
SELECT *
FROM PortfolioProject..Maternal_COVID_Death_Comparison


/*
Queries used for Tableau Project
*/


-- 1. Maternal Mortality by the Numbers 
Select m1.continent, m1.country, m1.code, maternal_deaths_2017, maternal_death_per_100000_2017, lifetime_risk_of_maternal_death, maternal_mortality_ratio
FROM PortfolioProject..Maternal_COVID_Death_Comparison AS m1
INNER JOIN PortfolioProject..LifetimeRiskMaternalDeath AS lr
	ON m1.code = lr.code
	AND lr.year = 2017
INNER JOIN PortfolioProject..MaternalMortalityRatio AS mm
	ON m1.code = mm.code
	AND mm.year = 2017


-- 2. Total Maternal Deaths by Continent - Bar Chart
SELECT continent, SUM(maternal_deaths_2017) AS total_deaths, AVG(maternal_death_per_100000_2017) AS avg_deaths
FROM PortfolioProject..Maternal_COVID_Death_Comparison
GROUP BY continent


-- 3. Lifetime Risk by Country - Map
SELECT rc.continent, lr.entity AS country, CAST(lifetime_risk_of_maternal_death AS double precision) AS percentage_of_women_expected_to_die
FROM PortfolioProject..LifetimeRiskMaternalDeath AS lr
LEFT JOIN PortfolioProject..RegionCodes AS rc
	ON lr.code = rc.iso_code
WHERE lr.year = 2017


-- 4. Maternal Mortality Ratio - Bubble Chart
SELECT continent, mr.entity AS country, CAST(maternal_mortality_ratio AS double precision) AS maternal_mortality_ratio, CAST(population AS double precision) AS population
FROM PortfolioProject..MaternalMortalityRatio AS mr
INNER JOIN PortfolioProject..LifetimeRiskMaternalDeath AS lr
	ON mr.code = lr.code
	AND mr.year = lr.year
INNER JOIN PortfolioProject..RegionCodes AS rc
	ON mr.code = rc.iso_code
WHERE mr.year = 2017
AND continent IS NOT NULL and continent != ''
ORDER BY mr.entity