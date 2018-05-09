# League of Legends Draft Pick Engine
*A capstone project for the Springboard course Introduction to Data Science.*
### Introduction:
League of Legends (LoL) is a multiplayer online battle arena videogame by Riot Games.  The primary game mode for LoL is Summoner's Rift (which is also the name of the map, or arena), in which two teams of five players vie to destroy their opponents' base, called the Nexus.  Each player chooses one of 140 unique avatars, called champions, to represent them, and each champion has its own unique blend of attributes, skills, and abilities.

For more detailed information about the game, please see <a href="https://en.wikipedia.org/wiki/League_of_Legends#Gameplay" target="_blank">League of Legends on Wikipedia.</a>

One of the main player-versus-player (PvP) formats for the Summoner's Rift game mode, and the format established in most professional LoL tournaments (aka eSports), is Draft Pick.  In the Draft Pick format, each team takes turns in first, banning certain champions which prevents their opponents from drafting them (alas, while also preventing your own team from drafting them), and then, second, drafting their champions for the match.  In tournaments, the ban and draft process is as shown below:

1) First ban phase: A-B-A-B-A-B
2) First draft phase: A-BB-AA-B
3) Second ban phase: B-A-B-A
4) Second draft phase: B-AA-B
5) Trading phase: teammates swap each others' draft choices

For details about the Draft Pick PvP game mode please see the <a href="http://leagueoflegends.wikia.com/wiki/Draft_Pick" target="_blank">League of Legends Wiki Page.</a>


## What is the problem you want to solve?

There are many variables that can factor into drafting and banning champions.  For example:
- banning a champion that the best player on the opposing team was most successful playing as
- drafting a champion who is considered as having a tactical advantage against a champion an opponent drafted (i.e., drafting a "scissors" to counter an opponent drafting a "paper")
- drafting a champion to prevent the other team from drafting that champion themselves
- banning a champion that is considered to be overpowered (OP) by the LoL community

In professional tournaments and leagues, teams usually have coaches who guide their players during the draft phase.  When these eSports matches are broadcast live, there is also a commentary team that provides discussion about the draft phase.

The problem is a matter of time.  In order for these LoL eSports coaches and teams to currently make wise decisions in which chmapions to draft and which champions to ban, they have to have a scouting team going over dozens of hours of game replays for both their own teams and their opponents in addition to the team's players honing their own skills through dozens of hours of practice.  Because of the parity of the skill levels of professional LoL eSports players, the drafting and banning phase can sometimes be the deciding factor in a match.

While the human element and the "eye test" is still highly relevant, I want to provide an AI-driven, objective solution for champion bans and selections for LoL eSports teams.


## Who is your client and why do they care about this problem? In other words, what will your client DO or DECIDE based on your analysis that they wouldn’t have otherwise?

Professional and semi-pro LoL eSports players and coaches can use this solution to make better decisions in the draft phase in league and tournament play.  Broadcasters of these eSports can use this solution as an extra opinion for the audience to observe.  Finally, non-professional or casual players can use this solution while playing ranked PvP matches in which the tournament-style draft phase is implemented.


## What data are you going to use for this? How will you acquire this data?

Almost all the data to used for this project will come from the <a href="https://developer.riotgames.com/api-methods" target="_blank">Riot Games Developer website.</a>  

httr will be used to make the web API calls, and jsonlite will be used to convert the JSON responses of these API calls into R objects.

I may also use other third party websites that provide certain data, such as winning percentages for champions.


## In brief, outline your approach to solving this problem (knowing that this might change later).

My approach to solving this problem will be to gather recent match history of eSports players participating in Riot Games' two official professional leagues, the European League of Legends Championship Series (EU LCS) and the North American League of Legends Championship Series (NA LCS).  While these players' match data for league and tournament play isn't accessible without knowing the tournament ID number, I can still acquire the their match data on games played on the public servers (i.e., where regular people play LoL).
