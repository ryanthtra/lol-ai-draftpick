library(httr)
library(dplyr)

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
get_acs_summoner_by_name_and_region <- function(str_name, str_region) {
  uri <- paste(acs_prefix_domain, "/v1/players?name=", str_name, "&region=", str_region, sep = "")
  print(uri)
  response <- GET(uri)
  if (response$status_code == 200) {
    json <- jsonlite::fromJSON(content(response, as = "text"))
    return(json)
  }
}

get_acs_player_history_by_platform_and_account_id <- function(chr_platform_id = "EUW1", num_account_id = 23402463) {
  uri <- paste(acs_prefix_domain, "/v1/stats/player_history/", chr_platform_id, "/", num_account_id, sep = "")
  print(uri)
  response <- GET(uri)
  if (response$status_code == 200) {
    json <- jsonlite::fromJSON(content(response, as = "text"))
    return(json)
  }
}

get_acs_match_by_matchid <- function(chr_platform_id, num_match_id, chr_game_hash = "") {
  uri <- paste(acs_prefix_domain, "/v1/stats/game/", chr_platform_id, "/", num_match_id, ifelse(chr_game_hash != "", paste("?gameHash=", chr_game_hash, sep = ""), ""), sep = "")
  print(uri)
  response <- GET(uri)
  if (response$status_code == 200) {
    json <- jsonlite::fromJSON(content(response, as = "text"))
    return(json)
  }
}

get_acs_match_timeline_by_matchid <- function(chr_platform_id, num_match_id, chr_game_hash = "") {
  uri <- paste(acs_prefix_domain, "/v1/stats/game/", chr_platform_id, "/", num_match_id, "/timeline", ifelse(chr_game_hash != "", paste("?gameHash=", chr_game_hash, sep = ""), ""), sep = "")
  print(uri)
  response <- GET(uri)
  if (response$status_code == 200) {
    json <- jsonlite::fromJSON(content(response, as = "text"))
    return(json)
  }
}
######################################
# End -- API methods
######################################

######################################
# Helper methods
######################################

get_league_match_data_list <- function(league_matchid_list) {
  matchlist <- apply(league_matchid_list[, c('Region.ID', 'Game.ID', 'Hash.ID', 'Blue.Team', 'Red.Team')], 1, function(row) {
    return(get_acs_match_by_matchid(row[1], row[2], chr_game_hash = row[3]))
  })

  return(matchlist)
}

######################################
# End -- Helper methods
######################################


# NA LCS 2018 Spring Split -- Regular Season and Playoffs
nalcs_matchid_list <- read.csv("NALCS_Spring2018.csv")
# EU LCS 2018 Spring Split -- Regular Season and Playoffs
eulcs_matchid_list <- read.csv("EULCS_Spring2018.csv")


#for (i in 1:length(nalcs_f_matchids$gameids)) {
#nalcs_f_matches[[paste("game", i, sep="")]] <- get_acs_match_by_matchid(nalcs_id, nalcs_f_matchids$gameids[i], chr_game_hash = nalcs_f_matchids$hashes[i])
#nalcs_f_timelines[i] <- get_acs_match_timeline_by_matchid(nalcs_id, nalcs_f_matchids$gameids[i], chr_game_hash = nalcs_f_matchids$hashes[i])
#}

nalcs_matches <- get_league_match_data_list(nalcs_matchid_list)

# Get the "teams" data frame, which contains who won/lost, first blood, first baron, etc.
# Will need to wrangle so that team names are in each row, "Team 100/200" is changed to Blue/Red,
# and each entry in the list is concatenated into a large list, in order to do data visualization.
nalcs_matches_teams <- lapply(nalcs_matches, function(row) {
  #TODO: obtain team names of each match 


  return(row$teams)
})