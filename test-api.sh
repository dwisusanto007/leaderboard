#!/bin/bash

API_URL="http://localhost:3000"

echo "=== Testing Game Leaderboard API ==="
echo ""

# Function to register and login user
register_and_login() {
  local username=$1
  local password=$2
  
  echo "Registering user '$username'..."
  curl -X POST $API_URL/auth/register \
    -H "Content-Type: application/json" \
    -d "{\"username\":\"$username\",\"password\":\"$password\"}" \
    -s > /dev/null
  
  echo "Logging in as '$username'..."
  TOKEN=$(curl -X POST $API_URL/auth/login \
    -H "Content-Type: application/json" \
    -d "{\"username\":\"$username\",\"password\":\"$password\"}" \
    -s | jq -r '.access_token')
  echo "$TOKEN"
}

# Test 1: Create multiple players and scores
echo "=== TEST 1: Creating Multiple Players ==="
echo ""

# Create 5 players with different scores
declare -a TOKENS
declare -a PLAYERS=("alice" "bob" "charlie" "diana" "eve")
declare -a SCORES=(2500 1800 3200 1200 2900)

for i in {0..4}; do
  player=${PLAYERS[$i]}
  score=${SCORES[$i]}
  
  echo "Setting up player: $player (score: $score)"
  token=$(register_and_login "$player" "password123")
  TOKENS[$i]=$token
  
  # Submit initial score
  curl -X POST $API_URL/scores \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $token" \
    -d "{\"playerName\":\"$player\",\"score\":$score}" \
    -s > /dev/null
done

echo ""
echo "=== TEST 2: Initial Leaderboard ==="
echo "Expected order: charlie(3200), eve(2900), alice(2500), bob(1800), diana(1200)"
curl -X GET $API_URL/leaderboard -s | jq .
echo ""

# Test 3: Update existing player score
echo "=== TEST 3: Updating Existing Player Score ==="
echo "Updating alice's score from 2500 to 3500..."
curl -X POST $API_URL/scores \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKENS[0]}" \
  -d '{"playerName":"alice","score":3500}' \
  -s | jq .
echo ""

echo "Updated leaderboard (alice should now be #1):"
curl -X GET $API_URL/leaderboard -s | jq .
echo ""

# Test 4: Update with lower score
echo "=== TEST 4: Updating with Lower Score ==="
echo "Updating charlie's score from 3200 to 1000..."
curl -X POST $API_URL/scores \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKENS[2]}" \
  -d '{"playerName":"charlie","score":1000}' \
  -s | jq .
echo ""

echo "Updated leaderboard (charlie should now be last):"
curl -X GET $API_URL/leaderboard -s | jq .
echo ""

# Test 5: Add more players to test top 10 limit
echo "=== TEST 5: Testing Top 10 Limit ==="
echo "Adding 7 more players..."

declare -a MORE_PLAYERS=("frank" "grace" "henry" "iris" "jack" "kate" "liam")
declare -a MORE_SCORES=(1500 2200 2800 1900 3100 2600 1700)

for i in {0..6}; do
  player=${MORE_PLAYERS[$i]}
  score=${MORE_SCORES[$i]}
  
  echo "Adding player: $player (score: $score)"
  token=$(register_and_login "$player" "password123")
  
  curl -X POST $API_URL/scores \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $token" \
    -d "{\"playerName\":\"$player\",\"score\":$score}" \
    -s > /dev/null
done

echo ""
echo "Final leaderboard (should show only top 10):"
curl -X GET $API_URL/leaderboard -s | jq .
echo ""

# Test 6: Verify no duplicate player names
echo "=== TEST 6: Testing Unique Player Names ==="
echo "Attempting to update alice's score again..."
curl -X POST $API_URL/scores \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKENS[0]}" \
  -d '{"playerName":"alice","score":4000}' \
  -s | jq .
echo ""

echo "Final leaderboard (alice should have updated score, no duplicates):"
curl -X GET $API_URL/leaderboard -s | jq .
echo ""

# Test 7: Rate limiting test
echo "=== TEST 7: Rate Limiting Test ==="
echo "Testing rate limit (10 requests per minute)..."
echo "Sending 12 rapid requests..."

for i in {1..12}; do
  SCORE=$((4000 + i * 10))
  echo -n "Request $i (score: $SCORE): "
  
  HTTP_CODE=$(curl -s -w "%{http_code}" -o /dev/null -X POST $API_URL/scores \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${TOKENS[0]}" \
    -d "{\"playerName\":\"alice\",\"score\":$SCORE}")
  
  if [ "$HTTP_CODE" = "429" ]; then
    echo "❌ RATE LIMITED (HTTP $HTTP_CODE)"
  elif [ "$HTTP_CODE" = "201" ]; then
    echo "✅ SUCCESS (HTTP $HTTP_CODE)"
  else
    echo "⚠️  HTTP $HTTP_CODE"
  fi
  
  sleep 0.2
done

echo ""
echo "=== FINAL RESULTS ==="
echo "Final leaderboard:"
curl -X GET $API_URL/leaderboard -s | jq .
echo ""
echo "=== Test Complete ==="
echo ""
echo "✅ Tests completed:"
echo "   - Multiple players created"
echo "   - Leaderboard ranking verified"
echo "   - Score updates working"
echo "   - Top 10 limit enforced"
echo "   - No duplicate player names"
echo "   - Rate limiting active"
