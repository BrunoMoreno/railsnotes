# Notes API

RESTful API for managing notes and categories, built with Ruby on Rails 8 (API-only mode) with cookie-based session authentication (via `has_secure_password`).

## Tech stack

- [Ruby](https://www.ruby-lang.org/) **4.0.6** (see `.ruby-version`)
- [Ruby on Rails](https://rubyonrails.org/) **8.1** (API-only)
- [SQLite](https://www.sqlite.org/) as the database
- [Puma](https://github.com/puma/puma) as the web server
- [rack-cors](https://github.com/cyu/rack-cors) for Cross-Origin Resource Sharing

## Getting started

### Requirements

- Ruby 4.0.6
- Bundler

### Setup

```sh
bin/setup
```

This installs dependencies, creates the databases, and loads the seed data.

Start the server:

```sh
bin/dev
```

The API will be available at `http://localhost:3000`.

## API endpoints

Requests and responses use JSON (`Content-Type: application/json`). Except for authentication, the health check, and the welcome message, all endpoints require a valid session cookie (set after signup/sign-in).

### Authentication

| Method | Endpoint | Description |
| ------ | -------- | ----------- |
| `POST` | `/signup` | Create a user and sign in (sets `session_id` cookie) |
| `POST` | `/session` | Sign in (sets `session_id` cookie) |
| `DELETE` | `/session` | Sign out |
| `POST` | `/passwords` | Request password reset instructions |
| `PATCH` | `/passwords/:token` | Reset password using the token from the reset email |

#### Sign up

```sh
curl -X POST http://localhost:3000/signup \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email_address": "demo@example.com",
      "password": "password",
      "password_confirmation": "password"
    }
  }'
```

#### Sign in

```sh
curl -X POST http://localhost:3000/session \
  -H "Content-Type: application/json" \
  -b cookies.txt -c cookies.txt \
  -d '{
    "email_address": "demo@example.com",
    "password": "password"
  }'
```

(`-b`/`-c` keep the `session_id` cookie across `curl` calls — the README examples use it implicitly.)

### Health check

| Method | Endpoint | Description |
| ------ | -------- | ----------- |
| `GET` | `/up` | Health check endpoint |
| `GET` | `/` | Welcome message |

### Notes

| Method | Endpoint | Description |
| ------ | -------- | ----------- |
| `GET` | `/api/v1/notes` | List all notes |
| `POST` | `/api/v1/notes` | Create a note |
| `GET` | `/api/v1/notes/:id` | Show a single note |

#### Create a note

```sh
curl -X POST http://localhost:3000/api/v1/notes \
  -H "Content-Type: application/json" \
  -b cookies.txt -c cookies.txt \
  -d '{
    "note": {
      "title": "Minha nota",
      "content": "Conteúdo da nota",
      "is_public": true,
      "category_id": 1
    }
  }'
```

**Note attributes:**

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `title` | string | Note title |
| `content` | text | Note body |
| `is_public` | boolean | Whether the note is public |
| `category_id` | integer | ID of the associated category (**required**) |

Notes are owned by the signed-in user: `index` and `show` only return notes belonging to the current user, and `create` links the note to the current user automatically (`user_id` is not accepted as a parameter).

### Categories

| Method | Endpoint | Description |
| ------ | -------- | ----------- |
| `GET` | `/api/v1/categories` | List all categories |
| `POST` | `/api/v1/categories` | Create a category |
| `GET` | `/api/v1/categories/:id` | Show a single category |
| `PATCH` / `PUT` | `/api/v1/categories/:id` | Update a category |
| `DELETE` | `/api/v1/categories/:id` | Destroy a category |

**Category attributes:**

| Attribute | Type | Description |
| --------- | ---- | ----------- |
| `title` | string | Category title |
| `slug` | string | URL-friendly slug (auto-generated from `title` when blank) |

### Status codes

| Status | Meaning |
| ------ | ------- |
| `200` | Success |
| `201` | Created (signup / `POST`) |
| `204` | No content (`DELETE`) |
| `400` | Bad request (missing or empty params) |
| `401` | Unauthorized (missing/invalid session or invalid credentials) |
| `404` | Record not found |
| `422` | Unprocessable entity (validation errors) |

## Data model

- **User** has many **Notes** and **Sessions** (`dependent: :destroy`).
- **Category** has many **Notes** (`dependent: :destroy`). Deleting a category deletes its notes.
- **Note** belongs to a **Category** and to a **User**; a note without either is invalid.
- Category slugs are generated automatically from the title (via `title.parameterize`) when blank or when the title changes.
- The demo seed user is `demo@example.com` / `password`.

## Seed data

Load/demo data for categories and notes:

```sh
bin/rails db:seed
```

## Running tests

The test suite uses Minitest:

```sh
bin/rails test
```

Run the full CI pipeline (style, security, and tests) locally:

```sh
bin/ci
```

## Deployment

The project includes a [Dockerfile](Dockerfile) and [Kamal](https://kamal-deploy.org) deployment configuration (`config/deploy.yml`). See the sample hooks under `.kamal/hooks/`.