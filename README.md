# Project details

The general aims of the project:
- provide tools for editing multilingual texts,,
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
