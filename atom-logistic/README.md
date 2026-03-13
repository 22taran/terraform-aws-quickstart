# Logistics Application

A full-stack logistics app with **Cognito** authentication and **RDS** (PostgreSQL). Designed for:
- **Frontend**: Static site → CloudFront + S3
- **Backend**: Node.js API → ECS (Fargate)

Isolated in `sample-app/` — no Terraform integration. Deploy via CodeBuild.

## Structure

```
sample-app/
├── backend/          # Node.js API (ECS)
│   ├── server.js
│   ├── routes/
│   ├── middleware/
│   ├── db/
│   └── Dockerfile
├── frontend/          # React + Vite (CloudFront)
│   ├── src/
│   └── ...
├── buildspec.yml      # CodeBuild
└── env.example
```

## Features

- **Auth**: Cognito (email/password, sign up, confirm, sign in)
- **Shipments**: Create, list, update status, delete
- **Tracking**: Public tracking by tracking number
- **DB**: PostgreSQL with `shipments` and `tracking_events` tables

## Local development

### Backend

```bash
cd backend
npm install
# Set env vars (or use .env)
export DB_HOST=localhost DB_PORT=5432 DB_NAME=logistics DB_USERNAME=postgres DB_PASSWORD=xxx
export COGNITO_USER_POOL_ID=xxx COGNITO_CLIENT_ID=xxx COGNITO_REGION=us-east-2
npm start
```

### Frontend

```bash
cd frontend
npm install
# For local dev, API is proxied to localhost:3000
# For Cognito, create a .env.local:
# VITE_COGNITO_USER_POOL_ID=xxx
# VITE_COGNITO_CLIENT_ID=xxx
npm run dev
```

### Database setup

Run the schema on your RDS/PostgreSQL:

```bash
psql "postgresql://user:pass@host:5432/dbname" -f backend/db/schema.sql
```

Or the backend auto-runs the schema on startup (creates tables if missing).

## CodeBuild deployment

### 1. Environment variables (CodeBuild)

- `ECR_REPO_NAME` — ECR repository name (e.g. `logistics-backend`)
- `AWS_REGION` — e.g. `us-east-2`
- `VITE_API_URL` — ALB URL for the backend (frontend build)
- `VITE_COGNITO_USER_POOL_ID` — Cognito user pool ID
- `VITE_COGNITO_CLIENT_ID` — Cognito app client ID

### 2. Update buildspec.yml

The buildspec builds the frontend (output in `frontend/dist`) and pushes the backend Docker image to ECR. Adjust `ECR_REPO_NAME` or pass it as an env var.

### 3. Frontend build with env

In CodeBuild, before `npm run build`, export:

```bash
export VITE_API_URL=$API_URL
export VITE_COGNITO_USER_POOL_ID=$COGNITO_USER_POOL_ID
export VITE_COGNITO_CLIENT_ID=$COGNITO_CLIENT_ID
```

### 4. Post-build

- **Frontend**: Upload `frontend/dist/*` to S3, invalidate CloudFront
- **Backend**: Use the pushed ECR image in your ECS task definition

## Backend API

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/` | No | Health check |
| GET | `/api/shipments` | Yes | List my shipments |
| GET | `/api/shipments/:id` | Yes | Get shipment details |
| GET | `/api/shipments/track/:num` | No | Track by tracking number |
| POST | `/api/shipments` | Yes | Create shipment |
| PATCH | `/api/shipments/:id/status` | Yes | Update status |
| DELETE | `/api/shipments/:id` | Yes | Delete shipment |

## Backend environment (ECS)

- `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USERNAME`, `DB_PASSWORD`
- `COGNITO_USER_POOL_ID`, `COGNITO_CLIENT_ID`, `COGNITO_REGION`
- `CORS_ORIGIN` — Allowed origin (e.g. CloudFront URL)
- `PORT` — Default 3000

## Frontend build env (Vite)

- `VITE_API_URL` — Backend base URL (e.g. `https://alb-xxx.elb.amazonaws.com`)
- `VITE_COGNITO_USER_POOL_ID`
- `VITE_COGNITO_CLIENT_ID`
