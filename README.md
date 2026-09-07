# Notes API

RESTful API for managing notes and categories, built with Ruby on Rails 8 (API-only mode).

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

All routes are scoped under `/api/v1`. Requests and responses use JSON (`Content-Type: application/json`).

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
| `201` | Created (`POST`) |
| `204` | No content (`DELETE`) |
| `400` | Bad request (missing or empty params) |
| `404` | Record not found |
| `422` | Unprocessable entity (validation errors) |

## Data model

- **Category** has many **Notes** (`dependent: :destroy`). Deleting a category deletes its notes.
- **Note** belongs to a **Category**; a note without a category is invalid.
- Category slugs are generated automatically from the title (via `title.parameterize`) when blank or when the title changes.

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