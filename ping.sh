#!/usr/bin/env bash

function puts(){
    RED='\033[0;31m'
    NC='\033[0m' # No Color
    printf "${RED}$1${NC}\n"
}

puts "Empty ATM"
curl --header "Content-Type: application/json" \
  --request DELETE \
  --data '{}' \
    http://localhost:9292/empty
echo

puts "Show balance"
curl http://localhost:9292/balance
echo

puts "Load infinite money"
curl --header "Content-Type: application/json" \
  --request PUT \
  --data '{}' \
    http://localhost:9292/put_infinite_money
echo

puts "Empty ATM"
curl --header "Content-Type: application/json" \
  --request DELETE \
  --data '{}' \
    http://localhost:9292/empty
echo


puts "Load some money to ATM again"
curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"50":"20", "25":"20", "5": "0", "2": "0", "1": "1"}' \
    http://localhost:9292/add_money
echo

puts "Try to get 223"
curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"sum":"223"}' \
    http://localhost:9292/give_money
echo

puts "Show fast search for 223"
curl --header "Content-Type: application/json" \
  --request GET \
  --data '{"sum":"223"}' \
    http://localhost:9292/fast_search
echo

puts "Show bruteforce search for 223"
curl --header "Content-Type: application/json" \
  --request GET \
  --data '{"sum":"223"}' \
    http://localhost:9292/brute_force
echo

puts "Show fast search for 100"
curl --header "Content-Type: application/json" \
  --request GET \
  --data '{"sum":"100"}' \
    http://localhost:9292/fast_search
echo

puts "Show bruteforce search for 100"
curl --header "Content-Type: application/json" \
  --request GET \
  --data '{"sum":"100"}' \
    http://localhost:9292/brute_force
echo

puts "Try to get 100"
curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"sum":"100"}' \
    http://localhost:9292/give_money
echo

puts "Show balance"
curl http://localhost:9292/balance
echo
