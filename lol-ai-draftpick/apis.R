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

######################################
# End -- Helper methods
######################################


# NA LCS 2018 Spring Split -- Regular Season and Playoffs
nalcs_matchid_df <- read.csv("NALCS_Spring2018.csv")
# EU LCS 2018 Spring Split -- Regular Season and Playoffs
#eulcs_matchid_df <- read.csv("EULCS_Spring2018.csv")

nalcs_matches <- get_league_match_data_list(nalcs_matchid_df)

nalcs_single_match <- get_acs_match_by_matchid(nalcs_matchid_df$Region.ID[[1]], nalcs_matchid_df$Game.ID[[1]], chr_game_hash = nalcs_matchid_df$Hash.ID[[1]])

# Get the "teams" data frame, which contains who won/lost, first blood, first baron, etc.
# Will need to wrangle so that team names are in each row, "Team 100/200" is changed to Blue/Red,
# and each entry in the list is concatenated into a large list, in order to do data visualization.
#nalcs_matches_teams <- list()
#nalcs_matches_teams <- sapply(1:ncol(nalcs_matches), function(i) {
#nalcs_matches_teams <- sapply(1:length(nalcs_matches), function(i) {
  ##Add team name column
  ##nalcs_matches[[i]]$teams["teamNames"] <- c(nalcs_matchid_df[i, c("Blue.Team", "Red.Team")])
  #nalcs_matches[[i]]$teams["teamNames"] <- unname(unlist(c(nalcs_matchid_df[i, c("Blue.Team", "Red.Team")])))
  ##nalcs_matches[, i]$teams["teamNames"] <- unname(unlist(c(nalcs_matchid_df[i, c("Blue.Team", "Red.Team")])))
  #return(nalcs_matches[[i]]$teams)
  ##return(nalcs_matches[, i]$teams)
#})
nalcs_matches_teams_accum <- data.frame(NULL)
for (i in 1:length(nalcs_matches)) {
  nalcs_matches[[i]]$teams["teamNames"] <- unname(unlist(c(nalcs_matchid_df[i, c("Blue.Team", "Red.Team")])))
  #nalcs_matches_teams[[i]] <- nalcs_matches[[i]]$teams
  nalcs_matches_teams_accum <- nalcs_matches_teams_accum %>% bind_rows(nalcs_matches[[i]]$teams)
}
#nalcs_matches_teams_accum <- nalcs_matches_teams[[1]]
#for (i in 2:length(nalcs_matches_teams)) {
  #nalcs_matches_teams_accum <- nalcs_matches_teams_accum %>% bind_rows(nalcs_matches_teams[[i]])
#}
#nalcs_single_match$teams["teamNames"] <- c(nalcs_matchid_df[1, c("Blue.Team", "Red.Team")])
#nalcs_single_match$teams["teamNames"] <- as.character(c(nalcs_matchid_df[1, c("Blue.Team", "Red.Team")]))
nalcs_single_match$teams["teamNames"] <- unname(unlist(c(nalcs_matchid_df[1, c("Blue.Team", "Red.Team")])))