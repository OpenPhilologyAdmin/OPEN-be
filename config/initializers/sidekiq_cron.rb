# frozen_string_literal: true

if Rails.env.production?
  Sidekiq::Cron::Job.create(
    name:  'Remove old invalid Projects on every Sunday',
    cron:  '0 0 * * SUN',
    class: 'RemoveInvalidProjectsJob'
  )
end
