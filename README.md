# README
Liam Kavanaugh

## Project Overview

This project is a Clash of Clans war analytics tool that fetches clan
war data from the Clash Of Clans API. This tool uses the API to make a
csv file for clan war data and clan war league data. The Shiny app
attached is used for providing quick analysis of clans and player
statistics including automated map placement, attack statistics, and
town hall differences.

## Prerequisites

- This project was created only with R code.

- The libraries used in this project consist of httr, jsonlite,
  tidyverse, and DT

- The project uses an API key from the Clash of Clans developer site
  (<https://developer.clashofclans.com/#/>)

## Project Structure

The project consists of 2 files for creating the csv files:

1.  ClanWarAttackWarlog.qmd

2.  ClanWarAttackWarlog.qmd

These files take an API key and a clan tag and format the data from wars
that are currently in progress.

The project also consists of a shiny app:

1.  app.R

app.R contains the analytics to perform player analysis based on war
performance in clan wars and clan war league. A data set containing the
data of a specific clan has to be manually added to the beginning of the
shiny app to use the data of that clan. The data set must also be in the
format that is provided from one of the 2 csv creation files listed
above.

The project also contains 2 data sets generated from the API:

1.  WarLog.csv

2.  LeagueWarLog.csv

These two data sets were obtained from the two data collection and
formatting files.

## Setup

In order to properly setup the project files, you must first download
the files into R studio. It is important to use R studio that is
installed on the machine you are connected to the internet on, in order
to properly use the API key generated from the Clash of Clans Developer
website.

After downloading the files into R studio, it is important to change the
clan tag and api key at the beginning of the ClanWarAttackWarlog.qmd and
ClanWarLeagueAttackWarlog.qmd files in these chunks:

``` r
## clan tag and api key 

clan_tag = "Enter Clan Tag Here"

api_key = "Enter API Key Here"
```

It is important to add this information individually in order to connect
to the API and get data for the desired clan.

## Running the App

After obtaining the proper data needed for analysis, the app will
automatically load in the data obtained from the
ClanWarAttackWarlog.qmd. The line of code to load in the data set in the
app may need to be altered if the desired data set was captured in the
ClanWarLeagueAttackWarlog.qmd file. In order for the app to
automatically load the proper data set, the data set must be in the same
directory as the app.

## Usage Guide

When opening the app, there will be a drop down box to select the
desired table. In some of the tables there will also be a text box to
enter a desired player tag. It is important to note the players tag must
be entered with the ‘\#’ before the string of numbers to properly use
the app.

### Shiny App Features

The available tables to select are as follows:

1.  Summary Table

    Summary Table provides a recommended map positioning for war based
    on the players town hall and attack performance.

2.  Player Statistics

    The player statistics table provides the data for each attack of the
    desired player whos tag must be entered into the side text box.
    There is also a drop down box on the left side of the app that
    allows the user to filter the data by attack order. i.e. first
    attack, second attack, and both attacks.

3.  Town Hall Difference Table

    The town hall difference table provides a table containing attacks
    that are ordered by the differnence in the town hall levels of the
    attacker and the defender. i.e. if the town hall difference number
    is negative, this means the attacking player attacked someone with a
    higher town hall then them. If the town hall difference is positive,
    it means the attacker attacked a player with a lower town hall than
    them. If the value is 0, the attacker and defender share the same
    town hall.

### Input Fields

1.  View Selection

    View Selection is a drop down box that allows the user to change
    between tables

2.  Player Tag

    Player tag is an input box that is available on Player Statistics
    and Town Hall Difference Table. This text box allows the user to
    view analytics of different players

3.  Attack Order

    Attack order allows the player to filter the data by attack order.
    i.e. first attack, second attack, and both attacks.
