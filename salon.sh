#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon Appointment Scheduler ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then 
    echo $1
  fi

  echo -e "\nWelcome! What service would you like?"

  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")

  if [[ -z SERVICES ]]
  then 
    MAIN_MENU "There are no services available right now."
  else
    echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
    do
      echo "$SERVICE_ID) $SERVICE_NAME"
    done
    SELECT_SERVICE
  fi
  
}

SCHEDULE_SERVICE() {
  echo -e "\nWhat time would you like your $(echo $ENTERED_SERVICE_NAME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
  read SERVICE_TIME

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
  APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")

  echo -e "\nI have put you down for a $(echo $ENTERED_SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
}

CUSTOMER_INFO() {
  echo -e "\nWhat is your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")

  if [[ -z $CUSTOMER_NAME ]]
  then 
    echo -e "\nThat phone number is not in the system. Please enter your name." 
    read CUSTOMER_NAME
    CUSTOMER_PHONE_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")
  fi

  SCHEDULE_SERVICE

}

SELECT_SERVICE() {
  read SERVICE_ID_SELECTED
  ENTERED_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
  if [[ -z $ENTERED_SERVICE_NAME ]]
  then 
    MAIN_MENU "The service you selected does not exist."
  else 
    CUSTOMER_INFO
  fi
}



MAIN_MENU
