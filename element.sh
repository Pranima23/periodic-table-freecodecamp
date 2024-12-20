#! /bin/bash

if [[ -z $1 ]]
then
    echo "Please provide an element as an argument."
    exit
else
    INPUT=$1
fi

PSQL="sudo -i -u postgres psql --dbname=periodic_table --no-align --tuples-only -c"

# get element from database
if [[ "$INPUT" =~ ^[0-9]+$ ]]
then
    ELEMENT=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE atomic_number='$INPUT'")
else
    ELEMENT=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE symbol='$INPUT' OR name='$INPUT'")
fi

if [[ -z $ELEMENT ]]
then
    echo "I could not find that element in the database."
    exit
fi

# get properties of selected element from database
IFS='|' read ATOMIC_NUMBER SYMBOL NAME <<< $ELEMENT
PROPERTY=$($PSQL "SELECT atomic_mass, melting_point_celsius, boiling_point_celsius, type_id FROM properties WHERE atomic_number='$ATOMIC_NUMBER'")

# get type of selected element from database
IFS='|' read ATOMIC_MASS MELTING_POINT BOILING_POINT TYPE_ID <<< $PROPERTY
TYPE=$($PSQL "SELECT type FROM types WHERE type_id='$TYPE_ID'")

echo -e "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
