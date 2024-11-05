#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~ The Salon ~~"

echo -e "\nWelcome to the Salon, how may I help you?"


MAIN_MENU() {

  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # SHOW ALL SERVICES
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  # IF NO SERVICES
  if [[ -z $SERVICES ]]
  then
    echo "Sorry, we currenly have no services available."
  
  else 
    # SHOW SERVICES LIST
    echo -e "$SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done

    # ASK FOR CHOICE
    echo -e "\nChoose a service"
    read SERVICE_ID_SELECTED

    # IF CHOICE IS NOT A NUMBER
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+* ]]
    then
      # SEND BACK TO MAIN
      MAIN_MENU "Please choose a number from the given options"

    else
      # CHECK IF SERVICE ID IS VALID
      VALIDATED_SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")

      # IF INVALID SEND TO MAIN MENU
      if [[ -z $VALIDATED_SERVICE_ID ]]
      then
        MAIN_MENU "No such service id."

      else
        # GET CUSTOMER PHONE NO
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE

        # SEARCH CUSTOMER DETAILS
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

        # IF CUSTOMER NOT FOUND
        if [[ -z $CUSTOMER_NAME ]]
        then
          echo -e "\nWhat's your name?"
          read CUSTOMER_NAME

          # CREATE CUSTOMER RECORD
          CUSTOMER_INSERT_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")

          SERVICE_NAME=$($PSQL "SELECT name from services where service_id = $VALIDATED_SERVICE_ID")

          # GET APPOINTMENT TIME
          echo -e "\nWhat time would you like to schedule your appointment?"
          read SERVICE_TIME

          # GET CUSTOMER ID
          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

          # CREATE APPOINTMENT RECORD
          APPOINTMENT_INSERT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $VALIDATED_SERVICE_ID,'$SERVICE_TIME')")

          # CONFIRMATION MESSAGE TO CUSTOMER
          echo -e "I have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."

      else
        # IF EXISTING CUSTOMER
        # GET APPOINTMENT TIME
          echo -e "\nWhat time would you like to schedule your appointment?"
          read SERVICE_TIME

          # GET CUSTOMER ID
          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")


          # CREATE APPOINTMENT RECORD
          APPOINTMENT_INSERT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES($CUSTOMER_ID, $VALIDATED_SERVICE_ID, '$SERVICE_TIME')")

          # CONFIRMATION MESSAGE TO CUSTOMER
          echo -e "I have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
        fi
      fi
    fi
  fi


}

MAIN_MENU


