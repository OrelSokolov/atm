#!/usr/bin/env bash
echo "Empty ATM"
curl --header "Content-Type: application/json" \
  --request DELETE \
  --data '{}' \
    http://localhost:9292/empty
echo

echo "Show balance"
curl http://localhost:9292/balance
echo

echo "Load infinite money"
curl --header "Content-Type: application/json" \
  --request PUT \
  --data '{}' \
    http://localhost:9292/put_infinite_money
echo

echo "Empty ATM"
curl --header "Content-Type: application/json" \
  --request DELETE \
  --data '{}' \
    http://localhost:9292/empty
echo


echo "Load some money to ATM again"
curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"50":"20", "25":"20", "5": "0", "2": "0", "1": "1"}' \
    http://localhost:9292/add_money
echo

echo "Try to get 223"
curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"sum":"223"}' \
    http://localhost:9292/give_money
echo

echo "Show fast search for 223"
curl --header "Content-Type: application/json" \
  --request GET \
  --data '{"sum":"223"}' \
    http://localhost:9292/fast_search
echo

echo "Show bruteforce search for 223"
curl --header "Content-Type: application/json" \
  --request GET \
  --data '{"sum":"223"}' \
    http://localhost:9292/brute_force
echo

echo "Show fast search for 100"
curl --header "Content-Type: application/json" \
  --request GET \
  --data '{"sum":"100"}' \
    http://localhost:9292/fast_search
echo

echo "Show bruteforce search for 100"
curl --header "Content-Type: application/json" \
  --request GET \
  --data '{"sum":"100"}' \
    http://localhost:9292/brute_force
echo

echo "Try to get 100"
curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"sum":"100"}' \
    http://localhost:9292/give_money
echo

echo "Show balance"
curl http://localhost:9292/balance
echo
