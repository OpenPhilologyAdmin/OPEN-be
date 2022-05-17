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

- `gem install bundler`
- `bundle install`
- `lefthook install -f`
- `rails db:setup`
- `rails server`
- application is running on `http://localhost:3000`

# Running tests and other services around the project

- `rspec spec` to run tests.

# API Docs

[Rswag](https://github.com/rswag/rswag/tree/2.3.0) is used to generate API docs semi-automatically.

Documentation is generated in [OpenAPI 3.0.1 interface](https://swagger.io/specification/) based on integration specs built for controllers.

Please use `rails generate rspec:swagger Ver1::ControllerName` to generate a plain spec file for the controller.
Please enclose specs used to define documentation files in a context with `swagger: true` tag, eg: `context 'swagger docs generation', swagger: true do ... end`.
These will be automatically excluded from "normal" specs. Only tests tagged as `swagger: true` will be used to generate docs.

Once tests are ready, use `RAILS_ENV=test rails rswag` command to generate the JSON file, and `/api-docs` endpoint to preview the documentation in swagger UI.
