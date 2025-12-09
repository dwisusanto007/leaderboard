# Game Leaderboard API

<!-- This project structure was generated with AI assistance -->

A RESTful API for a mobile game leaderboard built with NestJS, TypeScript, PostgreSQL, and Docker.

## Features

- JWT-based authentication
- Role-based authorization (users and admins)
- Rate limiting on score submissions
- Request logging with IP tracking
- PostgreSQL database
- Docker containerization

## Prerequisites

- Docker and Docker Compose
- Node.js 14+ (for local development)

## Quick Start with Docker

1. Start the application:
```bash
docker-compose up --build
```

The API will be available at `http://localhost:3000`

## API Endpoints

### Authentication

#### Register a new user
```bash
POST /auth/register
Content-Type: application/json

{
  "username": "player1",
  "password": "password123"
}
```

#### Login
```bash
POST /auth/login
Content-Type: application/json

{
  "username": "player1",
  "password": "password123"
}
```

Response:
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### Scores

#### Submit a score (Authenticated)
```bash
POST /scores
Authorization: Bearer <your_jwt_token>
Content-Type: application/json

{
  "playerName": "player1",
  "score": 1500
}
```

**Rate Limit:** 10 requests per minute

**Authorization Rules:**
- Regular users can only submit scores for themselves (playerName must match their username)
- Admins can submit scores for any player

#### Get leaderboard (Public)
```bash
GET /leaderboard
```

Response:
```json
[
  {
    "playerName": "player1",
    "score": 1500
  },
  {
    "playerName": "player2",
    "score": 1200
  }
]
```

## Local Development

1. Install dependencies:
```bash
npm install
```

2. Start PostgreSQL (or use Docker):
```bash
docker run -d \
  --name postgres \
  -e POSTGRES_USER=gameuser \
  -e POSTGRES_PASSWORD=gamepass123 \
  -e POSTGRES_DB=leaderboard \
  -p 5432:5432 \
  postgres:13-alpine
```

3. Update `.env` file with your configuration

4. Run the application:
```bash
npm run start:dev
```

## Environment Variables

- `DB_HOST`: Database host (default: postgres)
- `DB_PORT`: Database port (default: 5432)
- `DB_USERNAME`: Database username (default: gameuser)
- `DB_PASSWORD`: Database password (default: gamepass123)
- `DB_DATABASE`: Database name (default: leaderboard)
- `JWT_SECRET`: Secret key for JWT signing
- `JWT_EXPIRATION`: JWT token expiration time (default: 24h)

## Logging

All requests are logged to `logs/requests.log` with the following information:
- Timestamp
- Client IP address
- HTTP method
- Endpoint
- Response status code
- Request duration

## Creating an Admin User

To create an admin user, you need to manually update the database:

```sql
UPDATE users SET "isAdmin" = true WHERE username = 'admin_username';
```

## Testing the API

Example workflow:

1. Register a user:
```bash
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"player1","password":"password123"}'
```

2. Login:
```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"player1","password":"password123"}'
```

3. Submit a score (use the token from login):
```bash
curl -X POST http://localhost:3000/scores \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{"playerName":"player1","score":1500}'
```

4. View leaderboard:
```bash
curl http://localhost:3000/leaderboard
```

## Stopping the Application

```bash
docker-compose down
```

To remove volumes as well:
```bash
docker-compose down -v
```
