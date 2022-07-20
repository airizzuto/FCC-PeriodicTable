#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

# checks for existing argument
if [[ -z "$1" ]] 
then
  echo "Please provide an element as an argument."
else
  # if element arg is not id
  if [[ ! $1 =~  ^[0-9]+$ ]]
  then
    # search for element id
    ELEMENT_TO_SEARCH=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$1' OR name='$1';")
  else
    ELEMENT_TO_SEARCH=$1
  fi

  # retrieve element data
  ELEMENT_SEARCH_RESULT=$($PSQL "
    SELECT
      e.atomic_number, e.symbol, e.name,
      p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius,
      t.type
    FROM elements AS e
    FULL JOIN properties AS p USING(atomic_number)
    INNER JOIN types AS t USING(type_id)
    WHERE e.atomic_number=$ELEMENT_TO_SEARCH;
  ")

  if [[ -z $ELEMENT_SEARCH_RESULT ]]
  then
    echo "I could not find that element in the database."
  else
    # output element data
    echo "$ELEMENT_SEARCH_RESULT" | while read NUMBER BAR SYMBOL BAR NAME BAR MASS BAR MELTING_POINT BAR BOILING_POINT BAR TYPE
    do
      echo "The element with atomic number $NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
    done
  fi
fi
