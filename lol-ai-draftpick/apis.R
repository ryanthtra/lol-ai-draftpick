library(httr)
library(dplyr)
#library(future)

#prefix_domain <- "https://na1.api.riotgames.com"

# This api_token will eventually go in a separate file which will be ignored by git.
#api_token <- "RGAPI-afa7ca6b-3ccd-465d-90c4-51616b4fabb8"


# get_summoner_by_name <- function(str_name) {
#   response <- GET(paste(prefix_domain, "/lol/summoner/v3/summoners/by-name/", str_name, sep = ""), add_headers("X-Riot-Token" = api_token))
#   if (response$status_code == 200) {
#     json <- jsonlite::fromJSON(content(response, as = "text"))
#     return (json)
#   }
# }
# 
# 
# get_matchlist_by_accountid_and_season <- function(num_accountid, num_season) {
#   response <- GET(paste(prefix_domain, "/lol/match/v3/matchlists/by-account/", num_accountid, "?season=", num_season, sep = ""), add_headers("X-Riot-Token" = api_token))
#   if (response$status_code == 200) {
#     json <- jsonlite::fromJSON(content(response, as = "text"))
#     return (json)
#   }
# }
# 
# 
# get_match_by_matchid <- function(num_matchid) {
#   response <- GET(paste(prefix_domain, "/lol/match/v3/matches/", num_matchid, sep = ""), add_headers("X-Riot-Token" = api_token))
#   if (response$status_code == 200) {
#     json <- jsonlite::fromJSON(content(response, as = "text"))
#     return (json)
#   }
# }
# 
# 
# get_match_timeline_by_matchid <- function(num_matchid) {
#   response <- GET(paste(prefix_domain, "/lol/match/v3/timelines/by-match/", num_matchid, sep = ""), add_headers("X-Riot-Token" = api_token))
#   if (response$status_code == 200) {
#     json <- jsonlite::fromJSON(content(response, as = "text"))
#     return (json)
#   }
# }

acs_prefix_domain <- "https://acs.leagueoflegends.com"
#######################################################
# API calls using ACS domain
######################################

# API call helper from response
process_uri <- function(str_uri) {

  print(str_uri)
  #future_response <- future({
  #return (GET(str_uri))
  #}) %plan% multiprocess
  #response <- value(future_response)
  response <- GET(str_uri)
  print(response$status_code)
  while (response$status_code == 429) {
    Sys.sleep(2)
    response <- GET(str_uri)
  }
  json <- jsonlite::fromJSON(content(response, as = "text"))
  return(json)
}

get_acs_summoner_by_name_and_region <- function(str_name, str_region) {
  uri <- paste(acs_prefix_domain, "/v1/players?name=", str_name, "&region=", str_region, sep = "")
  return (process_uri(uri))
}

get_acs_player_history_by_platform_and_account_id <- function(chr_platform_id = "EUW1", num_account_id = 23402463) {
  uri <- paste(acs_prefix_domain, "/v1/stats/player_history/", chr_platform_id, "/", num_account_id, sep = "")
  return(process_uri(uri))
}

get_acs_match_by_matchid <- function(chr_platform_id, num_match_id, chr_game_hash = "") {
  uri <- paste(acs_prefix_domain, "/v1/stats/game/", chr_platform_id, "/", num_match_id, ifelse(chr_game_hash != "", paste("?gameHash=", chr_game_hash, sep = ""), ""), sep = "")
  return(process_uri(uri))
}

get_acs_match_timeline_by_matchid <- function(chr_platform_id, num_match_id, chr_game_hash = "") {
  uri <- paste(acs_prefix_domain, "/v1/stats/game/", chr_platform_id, "/", num_match_id, "/timeline", ifelse(chr_game_hash != "", paste("?gameHash=", chr_game_hash, sep = ""), ""), sep = "")
  return(process_uri(uri))
}
######################################
# End -- API methods
######################################

######################################
# Helper methods
######################################

get_league_match_data_list <- function(league_matchid_df) {
  # OLD FOR LOOP IMPLEMENTATION
  matchlist <- list()
  for (i in 1:nrow(league_matchid_df)) {
    matchlist[[i]] <- get_acs_match_by_matchid(league_matchid_df$Region.ID[[i]], league_matchid_df$Game.ID[[i]], chr_game_hash = league_matchid_df$Hash.ID[[i]])
  }

  #matchlist <- apply(league_matchid_df[c(1:10), c('Region.ID', 'Game.ID', 'Hash.ID', 'Blue.Team', 'Red.Team')], 1, function(row) {
  #current_match <- get_acs_match_by_matchid(row[1], row[2], chr_game_hash = row[3])
  #Sys.sleep(1.0)
  #return (current_match)
  #})

  ##matchlist <- sapply(1:10, function(i) {
  #matchlist <- sapply(1:nrow(league_matchid_df), function(i) {
    ##print(paste("API Call #", i, sep=""))
  #current_match <- get_acs_match_by_matchid(league_matchid_df$Region.ID[[i]], league_matchid_df$Game.ID[[i]], chr_game_hash = league_matchid_dfHash.ID[[i]])

    ##if ((i %% 14) == 0) {
    ##Sys.sleep(0.5)
    ##}
    #return(current_match)
  #})
  
  return(matchlist)
}

get_league_timeline_data_list <- function(league_matchid_df) {
  # OLD FOR LOOP IMPLEMENTATION
  timelinelist <- list()
  for (i in 1:nrow(league_matchid_df)) {
    timelinelist[[i]] <- get_acs_match_by_matchid(league_matchid_df$Region.ID[[i]], league_matchid_df$Game.ID[[i]], chr_game_hash = league_matchid_df$Hash.ID[[i]])
  }
  return(timelinelist)
}

get_accum_matches_teams <- function(league_matchlist, league_matchid_df) {
  league_matches_teams_accum <- data.frame(NULL)
  for (i in 1:length(league_matchlist)) {
    league_matchlist[[i]]$teams["teamNames"] <- unname(unlist(c(league_matchid_df[i, c("Blue.Team", "Red.Team")])))
    # Concatenate rows from current match onto the accumulation DF
    league_matches_teams_accum <- league_matches_teams_accum %>% bind_rows(league_matchlist[[i]]$teams)
  }
  #Change all teamId = 100/200 to Blue/Red
  league_matches_teams_accum <- league_matches_teams_accum %>%
    mutate(teamId = replace(teamId, grepl('100', teamId), 'Blue')) %>%
    mutate(teamId = replace(teamId, grepl('200', teamId), 'Red'))
  return (league_matches_teams_accum)
}


######################################
# End -- Helper methods
######################################


# NA LCS 2018 Spring Split -- Regular Season and Playoffs
nalcs_matchid_df <- read.csv("NALCS_Spring2018.csv")
# EU LCS 2018 Spring Split -- Regular Season and Playoffs
eulcs_matchid_df <- read.csv("EULCS_Spring2018.csv")
# MSI 2018 Play-In Stage
msipi_matchid_df <- read.csv("MSI_PlayInAll2018.csv")


nalcs_matches <- get_league_match_data_list(nalcs_matchid_df)
eulcs_matches <- get_league_match_data_list(eulcs_matchid_df)
msipi_matches <- get_league_match_data_list(msipi_matchid_df)

nalcs_single_match <- get_acs_match_by_matchid(nalcs_matchid_df$Region.ID[[1]], nalcs_matchid_df$Game.ID[[1]], chr_game_hash = nalcs_matchid_df$Hash.ID[[1]])

# Get the "teams" data frame, which contains who won/lost, first blood, first baron, etc.
# Will need to wrangle so that team names are in each row, "Team 100/200" is changed to Blue/Red,
# and each entry in the list is concatenated into a large list, in order to do data visualization.

nalcs_single_match$teams["teamNames"] <- unname(unlist(c(nalcs_matchid_df[1, c("Blue.Team", "Red.Team")])))

nalcs_matches_teams_accum <- get_accum_matches_teams(nalcs_matches, nalcs_matchid_df)
#na_win_blue <- nalcs_matches_teams_accum %>% filter(teamId == "Blue" & win == "Win")
#na_win_red <- nalcs_matches_teams_accum %>% filter(teamId == "Red" & win == "Win")
#na_win_firstblood <- nalcs_matches_teams_accum %>% filter(firstBlood == "TRUE" & win == "Win")
#na_win_firsttower <- nalcs_matches_teams_accum %>% filter(firstTower == "TRUE" & win == "Win")
#na_win_firstinhib <- nalcs_matches_teams_accum %>% filter(firstInhibitor == "TRUE" & win == "Win")
#na_win_firstbaron <- nalcs_matches_teams_accum %>% filter(firstBaron == "TRUE" & win == "Win")
#na_win_firstdragon <- nalcs_matches_teams_accum %>% filter(firstDragon == "TRUE" & win == "Win")
#na_win_riftheraldkill <- nalcs_matches_teams_accum %>% filter(riftHeraldKills == 1 & win == "Win")

na_bluered_avg_stats <- nalcs_matches_teams_accum %>%
  group_by(teamId) %>%
  summarise_each(funs(mean), towerKillAvg=towerKills, inhibitorKillAvg=inhibitorKills, baronKillAvg=baronKills, dragonKillAvg=dragonKills, riftHeraldKillAvg=riftHeraldKills)

#View(
  #nalcs_matches_teams_accum %>%
    #group_by(teamNames, teamId, win) %>%
    #tally(sort = FALSE))

#View(
  #nalcs_matches_teams_accum %>%
    #group_by(teamId, teamNames) %>%
    #select(win) %>%
    #table() 
#)

eulcs_matches_teams_accum <- get_accum_matches_teams(eulcs_matches, eulcs_matchid_df)
eu_win_blue <- eulcs_matches_teams_accum %>% filter(teamId == "Blue" & win == "Win")
eu_win_red <- eulcs_matches_teams_accum %>% filter(teamId == "Red" & win == "Win")
eu_bluered_avg_stats <- eulcs_matches_teams_accum %>%
  group_by(teamId) %>%
  summarise_each(funs(mean), towerKillAvg = towerKills, inhibitorKillAvg = inhibitorKills, baronKillAvg = baronKills, dragonKillAvg = dragonKills, riftHeraldKillAvg = riftHeraldKills)

msipi_matches_teams_accum <- get_accum_matches_teams(msipi_matches, msipi_matchid_df)
msipi_bluered_avg_stats <- msipi_matches_teams_accum %>%
  group_by(teamId) %>%
  summarise_each(funs(mean), towerKillAvg = towerKills, inhibitorKillAvg = inhibitorKills, baronKillAvg = baronKills, dragonKillAvg = dragonKills, riftHeraldKillAvg = riftHeraldKills)