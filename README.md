# Exploration of Data on Maternal Deaths Using SQL and Tableau

This is a repository for a personal project of mine that explores maternal mortality data from <a href="https://ourworldindata.org/maternal-mortality">OurWorldInData.org</a>.

The datasets and SQL code used in the project are included in this repository. This project was inspired by AlexTheAnalyst's 
<a href="https://youtu.be/qfyynHBFOsM">YouTube video on using SQL to explore data on COVID deaths</a>. 

## Introduction

Maternal mortality refers to the risk that a woman dies from a maternal death, which is defined as "a death while pregnant or within 42 days 
of the termination of the pregnancy, irrespective of the duration and site of the pregnancy, from any cause related to or aggravated by 
the pregnancy or its management but not from accidental or incidental causes" (<a href="https://ourworldindata.org/maternal-mortality">source</a>). 
In this project, I explored worldwide data from 2017 and focused on three metrics typically used in maternal mortality statistics:
<ol>
  <li><b>Total Number of Maternal Deaths:</b> The number of women who die from a maternal death, as defined above.</li>
  <li><b>Maternal Mortality Ratio:</b> The number of women who die from pregnancy-related causes while pregnant or within 42 days of pregnancy termination per 100,000 live births. This metric is the likelihood that a woman will die in a given pregnancy.</li>
  <li><b>Lifetime Risk of Maternal Death:</b> Defined as the probability that "a 15-year-old girl dies eventually from a pregnancy-related 
  cause assuming that the number of children per woman and the maternal mortality ratio remain at their current levels" (<a href="https://ourworldindata.org/maternal-mortality">source</a>). 
  This metric is the likelihood that a 15-year-old woman today will die from a maternal death sometime in the future.</li>
</ol> 

## Data Cleaning and Exploration Using SQL
All data cleaning and data exploration were done in SQL. The SQL code along with relevant comments can be found in this GitHub repository (<a href="https://github.com/VKwongData/MaternalDeaths/blob/main/Maternal_Deaths.sql">direct link to file</a>).

## Data Visualization Using Tableau
I also created the tables needed for the Tableau dashboard using SQL (the relevant code can be found in the <a href="https://github.com/VKwongData/MaternalDeaths/blob/main/Maternal_Deaths.sql">SQL file</a>). I used a different 
visualization for each of the metrics. The full interactive dashboard can be found on <a href="https://public.tableau.com/app/profile/vivian.kwong8697/viz/MaternalDeathsbytheNumbers2017/MaternalDeathsbytheNumbers2017">Tableau Public</a>. 




<b>Bar Chart of the Total Number of Maternal Deaths by Continent:</b>

![image](https://user-images.githubusercontent.com/94913441/181330786-ff3a0111-f05c-4ac0-8e52-840b81fc9987.png)


<b>Bubble Chart of the Maternal Mortality Ratio by Country and Continent:</b>

![MaternalMortalityRatioBubbleChart](https://user-images.githubusercontent.com/94913441/181334010-cd533722-135f-4f6c-9634-2dc7d44020ec.png)


<b>Map of the Lifetime Risk of Maternal Death by Country:</b>

![LifetimeRiskMap](https://user-images.githubusercontent.com/94913441/181339549-512f34b9-92a6-4c1f-990e-14cb29842f56.png)

