# frozen_string_literal: true

class RemoveInvalidProjectsJob < ApplicationJob
  DELAY = 7.days
  queue_as :default

  def perform
    Project.invalid
           .older_than(DELAY.ago)
           .destroy_all
  end
end
