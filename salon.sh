#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~   The Ever Salon   ~~~\n"

NUMBER_OF_SERVICES=$($PSQL "SELECT MAX(service_id) FROM services")

MAIN_MENU() {
# message handle
	if [[ $1 ]]
	then
		echo -e "\n$1\n"
  else
    echo -e "Please select an option.\n"
	fi

	# menu load
	SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")

	echo -e "$SERVICES" | while read SERVICE_ID BAR NAME
  do
			echo "$SERVICE_ID) $NAME"

	done

	read SERVICE_ID_SELECTED
	# check if input valid
	if [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]] && [[ $(($SERVICE_ID_SELECTED)) -le $(($NUMBER_OF_SERVICES)) ]] && [[ $SERVICE_ID_SELECTED > 0 ]]
	then
	  echo "What's your phone number? Use format 000-000-0000"
	  read CUSTOMER_PHONE
		CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
		
		# check if new customer
		if [[ -z $CUSTOMER_ID ]]
		then
			echo "I don't have a record for that phone number, what's your name?"
	    read CUSTOMER_NAME
	    ADD_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
			CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
		fi
		
		# schedule appointment
	  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
	  SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
	  CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/ |/"/')
	  SERVICE_FORMATTED=$(echo $SERVICE | sed 's/ |/"/')

	  echo "What time would you like your $SERVICE_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
	  read SERVICE_TIME
		SCHEDULE_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

		echo -e "\nI have put you down for a $SERVICE_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED.\n"
	else
		MAIN_MENU "Sorry, I don't understand, please enter a valid option."
	fi
}

MAIN_MENU