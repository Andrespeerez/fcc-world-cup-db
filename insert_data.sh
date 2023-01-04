#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo -e "\n~~ Truncate tables ~~\n"
echo "$($PSQL "TRUNCATE TABLE games, teams;")"
echo -e "\n~~ Insert data from file ~~\n"
cat games.csv | while IFS="," read YEAR ROUND W OP WGOALS OPGOALS
do
  # skip headers
  if [[ $YEAR != "year" ]]
  then
    echo "$YEAR $ROUND $W $OP $WGOALS $OPGOALS"
    # check winner and opponent are on db
    TEAM1=$($PSQL "SELECT name FROM teams WHERE name='$W'")
    TEAM2=$($PSQL "SELECT name FROM teams WHERE name='$OP'")
    # insert them into team if not found
    if [[ -z $TEAM1 ]]
    then
      INSERT_TEAM1=$($PSQL "INSERT INTO teams(name) VALUES('$W')")
    fi
    if [[ -z $TEAM2 ]]
    then
      INSERT_TEAM2=$($PSQL "INSERT INTO teams(name) VALUES('$OP')")
    fi
    # Get winner and opponent ID
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$W'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OP'")
    # Insert game to games
    INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WGOALS, $OPGOALS)")
  fi
done
# WORKING FINE!!!