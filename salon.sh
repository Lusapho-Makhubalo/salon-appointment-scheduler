#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  echo "Here are the services we offer:"

  # Get services - the query returns "id|name" because of --no-align
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  # Parse and print exactly "1) Cut" format
  echo "$SERVICES" | while IFS='|' read SERVICE_ID SERVICE_NAME
  do
    # trim any accidental spaces
    SERVICE_NAME=$(echo "$SERVICE_NAME" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  echo -e "\nPlease enter the service number you'd like:"
  read SERVICE_ID_SELECTED

  # Check if service exists (also checks if input is numeric-ish)
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_NAME ]]
  then
    echo -e "\nI could not find that service. What would you like today?"
    MAIN_MENU  # recursive → re-prints welcome + list
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      INSERT_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'), $(echo $CUSTOMER_NAME | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')?"
    read SERVICE_TIME

    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')."
  fi
}

MAIN_MENU
