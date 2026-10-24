#!/bin/bash

# if no argument
if [[ -z $1 ]]
then
  echo -e "Please provide an element as an argument."
else
  PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

  # TEST PSQL
  # test=$($PSQL "SELECT * FROM properties;")
  # echo $test

  ATOMIC_NUMBER=-1
  ELEMENT_SYMBOL=""
  ELEMENT_NAME=""
  RAW_SQL_OUTPUT=""

  # GET RAW SQL OUTPUT USING ONE QUERY - JOIN ON TYPE 
  # argument is atomic number (contains only digits via regex)
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    ATOMIC_NUMBER=$1
    RAW_SQL_OUTPUT=$($PSQL "SELECT e.name, e.symbol, p.atomic_number, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius FROM properties AS p FULL JOIN elements AS e USING(atomic_number) FULL JOIN types AS t USING(type_id) WHERE p.atomic_number = $ATOMIC_NUMBER;")
     
  # arugment is element symbol (1-2 characters)
  elif [[ ${#1} -le 2 ]]
  then 
    ELEMENT_SYMBOL=$1
    RAW_SQL_OUTPUT=$($PSQL "SELECT e.name, e.symbol, p.atomic_number, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius FROM properties AS p FULL JOIN elements AS e USING(atomic_number) FULL JOIN types AS t USING(type_id) WHERE e.symbol = '$ELEMENT_SYMBOL';")
  
  # arugment is element name (> 2 characters)
  else
    ELEMENT_NAME=$1
    RAW_SQL_OUTPUT=$($PSQL "SELECT e.name, e.symbol, p.atomic_number, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius FROM properties AS p FULL JOIN elements AS e USING(atomic_number) FULL JOIN types AS t USING(type_id) WHERE e.name = '$ELEMENT_NAME';")
  fi 

  # TEST RAW_SQL_OUTPUT
  # echo $RAW_SQL_OUTPUT

  # if not found
  if [[ -z $RAW_SQL_OUTPUT ]]
  then
    echo -e "I could not find that element in the database."
  else
    # use AWK to assign proper pieces to vars: elements.name, elements.symbol, properties(or elements).atomic_number, properties.type, properties.atomic_mass, properties.melting_point_celsius, properties.boiling_point_celsius, 
    ATOMIC_NUMBER=$(echo "$RAW_SQL_OUTPUT" | awk -F'|' '{print $3}')
    ELEMENT_NAME=$(echo "$RAW_SQL_OUTPUT" | awk -F'|' '{print $1}')
    ELEMENT_SYMBOL=$(echo "$RAW_SQL_OUTPUT" | awk -F'|' '{print $2}')
    ELEMENT_TYPE=$(echo "$RAW_SQL_OUTPUT" | awk -F'|' '{print $4}')
    ELEMENT_MASS=$(echo "$RAW_SQL_OUTPUT" | awk -F'|' '{print $5}')
    ELEMENT_MP=$(echo "$RAW_SQL_OUTPUT" | awk -F'|' '{print $6}')
    ELEMENT_BP=$(echo "$RAW_SQL_OUTPUT" | awk -F'|' '{print $7}')

    echo "The element with atomic number $ATOMIC_NUMBER is $ELEMENT_NAME ($ELEMENT_SYMBOL). It's a $ELEMENT_TYPE, with a mass of $ELEMENT_MASS amu. $ELEMENT_NAME has a melting point of $ELEMENT_MP celsius and a boiling point of $ELEMENT_BP celsius."

  fi
fi
