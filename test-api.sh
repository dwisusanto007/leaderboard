#!/bin/bash

API_URL="http://localhost:3000"

echo "=== Testing Game Leaderboard API ==="
echo ""

# Register user
echo "1. Registering user 'player1'..."
curl -X POST $API_URL/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"player1","password":"password123"}' \
  -s | jq .
echo ""

# Login
echo "2. Logging in as 'player1'..."
TOKEN=$(curl -X POST $API_URL/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"player1","password":"password123"}' \
  -s | jq -r '.access_token')
echo "Token: $TOKEN"
echo ""

# Submit score
echo "3. Submitting score..."
curl -X POST $API_URL/scores \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"playerName":"player1","score":1500}' \
  -s | jq .
echo ""

# Register another user
echo "4. Registering user 'player2'..."
curl -X POST $API_URL/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"player2","password":"password123"}' \
  -s | jq .
echo ""

# Login as player2
echo "5. Logging in as 'player2'..."
TOKEN2=$(curl -X POST $API_URL/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"player2","password":"password123"}' \
  -s | jq -r '.access_token')
echo ""

# Submit score for player2
echo "6. Submitting score for player2..."
curl -X POST $API_URL/scores \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN2" \
  -d '{"playerName":"player2","score":2000}' \
  -s | jq .
echo ""

# Get leaderboard
echo "7. Getting leaderboard..."
curl -X GET $API_URL/leaderboard -s | jq .
echo ""

echo "=== Test Complete ==="
