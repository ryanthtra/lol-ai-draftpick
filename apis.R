library(httr)

prefix_domain <- "https://na1.api.riotgames.com"
acs_prefix_domain <- "https://acs.leagueoflegends.com/"
# This api_token will eventually go in a separate file which will be ignored by git.
api_token <- "RGAPI-afa7ca6b-3ccd-465d-90c4-51616b4fabb8"


get_summoner_by_name <- function(str_name) {
  response <- GET(paste(prefix_domain, "/lol/summoner/v3/summoners/by-name/", str_name, sep = ""), add_headers("X-Riot-Token" = api_token))
  if (response$status_code == 200) {
    json <- jsonlite::fromJSON(content(response, as = "text"))
    return (json)
  }
}


get_matchlist_by_accountid_and_season <- function(num_accountid, num_season) {
  response <- GET(paste(prefix_domain, "/lol/match/v3/matchlists/by-account/", num_accountid, "?season=", num_season, sep = ""), add_headers("X-Riot-Token" = api_token))
  if (response$status_code == 200) {
    json <- jsonlite::fromJSON(content(response, as = "text"))
    return (json)
  }
}


get_match_by_matchid <- function(num_matchid) {
  response <- GET(paste(prefix_domain, "/lol/match/v3/matches/", num_matchid, sep = ""), add_headers("X-Riot-Token" = api_token))
  if (response$status_code == 200) {
    json <- jsonlite::fromJSON(content(response, as = "text"))
    return (json)
  }
}


get_match_timeline_by_matchid <- function(num_matchid) {
  response <- GET(paste(prefix_domain, "/lol/match/v3/timelines/by-match/", num_matchid, sep = ""), add_headers("X-Riot-Token" = api_token))
  if (response$status_code == 200) {
    json <- jsonlite::fromJSON(content(response, as = "text"))
    return (json)
  }
}


# API calls using ACS domain
get_acs_summoner_by_name_and_region <- function(str_name, str_region) {
  response <- GET(paste(acs_prefix_domain, "/v1/players?name=", str_name, "&region=", str_region, sep = ""))
  if (response$status_code == 200) {
    json <- jsonlite::fromJSON(content(response, as = "text"))
    return (json)
  }
}

get_acs_player_history_by_platform_and_account_id <- function(chr_platform_id = "EUW1", num_account_id = 23402463) {
  url <- paste(acs_prefix_domain, "/v1/stats/player_history/", chr_platform_id, "/", num_account_id, sep = "")
  url
  response <- GET(url)
  if (response$status_code == 200) {
    json <- jsonlite::fromJSON(content(response, as = "text"))
    return (json)
  }
}

get_acs_match_by_matchid <- function(chr_platform_id = "NA1", num_match_id = 23402463) {
  response <- GET(paste(acs_prefix_domain, "/v1/stats/game/", chr_platform_id, "/", num_match_id, sep = ""))
  if (response$status_code == 200) {
    json <- jsonlite::fromJSON(content(response, as = "text"))
    return (json)
  }
}

get_acs_match_timeline_by_matchid <- function(chr_platform_id = "NA1", num_match_id = 23402463) {
  response <- GET(paste(acs_prefix_domain, "/v1/stats/game/", chr_platform_id, "/", num_match_id, "/timeline", sep = ""))
  if (response$status_code == 200) {
    json <- jsonlite::fromJSON(content(response, as = "text"))
    return (json)
  }
}


my_summoner <- get_summoner_by_name("TSM%20Zven")
my_matchlist <- get_matchlist_by_accountid_and_season(my_summoner$accountId, 11)
my_match <- get_match_by_matchid(my_matchlist$matches$gameId[1])
my_timeline <- get_match_timeline_by_matchid(my_matchlist$matches$gameId[1])

acs_summoner <- get_acs_summoner_by_name_and_region("TSM%20Zven", "EUW1")
acs_history <- get_acs_player_history_by_platform_and_account_id(chr_platform_id = "EUW1", num_account_id = 23402463)
acs_match <- get_acs_match_by_matchid(num_match_id = my_matchlist$matches$gameId[1])
acs_timeline <- get_acs_match_timeline_by_matchid(num_match_id = my_matchlist$matches$gameId[1])
