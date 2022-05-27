# Project details

The general aims of the project:
- provide tools for editing multilingual texts,
- allow for easy export of edited text into standard word
processors/typesetters for further/final typesetting (for paper
publication),
- allow online display of editions, both as completed projects and in
process.

Useful links:
- [Jira board](https://xfive.atlassian.net/jira/software/c/projects/OPLU/boards/37)

# Technology stack

- Ruby v3.1.2
- Ruby on Rails v7.0.3

# Project setup instructions

- `cp .env.local.template .env.development.local`
- `cp .env.local.template .env.test.local`
- Set up ENV variables in `.env.development.local` and `.env.test.local`
- `gem install bundler`
- `bundle install`
- `lefthook install -f`
- `rails db:setup`
- `rails server`
- application is running on `http://localhost:3000`

# Running tests and other services around the project

- `rspec spec` to run tests.

# Testing CI locally

## Requirements

- [docker](https://www.docker.com/products/docker-desktop/)
- [act](https://github.com/nektos/act)

## Commands

- `act -P ubuntu-latest=lucasalt/act_base:latest` to run the actions locally

# API Docs

[Rswag](https://github.com/rswag/rswag/tree/2.3.0) is used to generate API docs semi-automatically.

Documentation is generated in [OpenAPI 3.0.1 interface](https://swagger.io/specification/) based on integration specs built for controllers.

Please use `rails generate rspec:swagger Ver1::ControllerName` to generate a plain spec file for the controller.
Please enclose specs used to define documentation files in a context with `swagger: true` tag, eg: `context 'swagger docs generation', swagger: true do ... end`.
These will be automatically excluded from "normal" specs. Only tests tagged as `swagger: true` will be used to generate docs.

Once tests are ready, use `RAILS_ENV=test rails rswag` command to generate the JSON file, and `/api-docs` endpoint to preview the documentation in swagger UI.
