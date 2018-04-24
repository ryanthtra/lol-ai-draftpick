library(httr)
library(dplyr)

#prefix_domain <- "https://na1.api.riotgames.com"
acs_prefix_domain <- "https://acs.leagueoflegends.com"
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


# API calls using ACS domain
get_acs_summoner_by_name_and_region <- function(str_name, str_region) {
  uri <- paste(acs_prefix_domain, "/v1/players?name=", str_name, "&region=", str_region, sep = "")
  print(uri)
  response <- GET(uri)
  if (response$status_code == 200) {
    json <- jsonlite::fromJSON(content(response, as = "text"))
    return (json)
  }
}

get_acs_player_history_by_platform_and_account_id <- function(chr_platform_id = "EUW1", num_account_id = 23402463) {
  uri <- paste(acs_prefix_domain, "/v1/stats/player_history/", chr_platform_id, "/", num_account_id, sep = "")
  print(uri)
  response <- GET(uri)
  if (response$status_code == 200) {
    json <- jsonlite::fromJSON(content(response, as = "text"))
    return (json)
  }
}

get_acs_match_by_matchid <- function(chr_platform_id, num_match_id, chr_game_hash = "") {
  uri <- paste(acs_prefix_domain, "/v1/stats/game/", chr_platform_id, "/", num_match_id, ifelse(chr_game_hash != "", paste("?gameHash=", chr_game_hash, sep = ""), ""), sep = "")
  print(uri)
  response <- GET(uri)
  if (response$status_code == 200) {
    json <- jsonlite::fromJSON(content(response, as = "text"))
    return (json)
  }
}

get_acs_match_timeline_by_matchid <- function(chr_platform_id, num_match_id, chr_game_hash = "") {
  uri <- paste(acs_prefix_domain, "/v1/stats/game/", chr_platform_id, "/", num_match_id, "/timeline", ifelse(chr_game_hash != "", paste("?gameHash=", chr_game_hash, sep = ""), ""), sep = "")
  print(uri)
  response <- GET(uri)
  if (response$status_code == 200) {
    json <- jsonlite::fromJSON(content(response, as = "text"))
    return (json)
  }
}


# my_summoner <- get_summoner_by_name("TSM%20Zven")
# my_matchlist <- get_matchlist_by_accountid_and_season(my_summoner$accountId, 11)
# my_match <- get_match_by_matchid(my_matchlist$matches$gameId[1])
# my_timeline <- get_match_timeline_by_matchid(my_matchlist$matches$gameId[1])
# 
# acs_summoner <- get_acs_summoner_by_name_and_region("TSM%20Zven", "EUW1")
# acs_history <- get_acs_player_history_by_platform_and_account_id(chr_platform_id = "EUW1", num_account_id = 23402463)
# acs_match <- get_acs_match_by_matchid(num_match_id = my_matchlist$matches$gameId[1])
# acs_timeline <- get_acs_match_timeline_by_matchid(num_match_id = my_matchlist$matches$gameId[1])

# NA LCS 2018 Spring Split Finals
nalcs_id = "TRLH1"
nalcs_f_gameids <- c(1002530069, 1002530071, 1002530072)
nalcs_f_hashes <- c("a774e6c7993c29fa", "f10c8835759ef621", "0e19ce71fe99bf30")
nalcs_f_matchids <- data.frame(gameids = nalcs_f_gameids, hashes = nalcs_f_hashes)
nalcs_f_matches <- list()
nalcs_f_timelines <- list()
for (i in 1:length(nalcs_finals_matchids$gameids)) {
  nalcs_f_matches[paste("game", i, sep="")] <- get_acs_match_by_matchid(nalcs_id, nalcs_f_matchids$gameids[i], chr_game_hash = nalcs_f_matchids$hashes[i])
  nalcs_f_timelines[i] <- get_acs_match_timeline_by_matchid(nalcs_id, nalcs_f_matchids$gameids[i], chr_game_hash = nalcs_f_matchids$hashes[i])
}
  

nalcs_s2_gameids <- c(1002520268)
nalcs_s2_hashes <- c("2a185e66a18d0314")
nalcs_s2_match <- get_acs_match_by_matchid(nalcs_id, nalcs_semis_m2_gameids[1], chr_game_hash = nalcs_semis_m2_hashes[1])
nalcs_s2_timeline <- get_acs_match_timeline_by_matchid(nalcs_id, nalcs_semis_m2_gameids[1], chr_game_hash = nalcs_semis_m2_hashes[1])
