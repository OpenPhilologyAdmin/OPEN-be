# frozen_string_literal: true

module Ver1
  class ProjectsController < ApiApplicationController
    before_action :require_login

    def create
      record = Project.new(permitted_attributes(Project))
      authorize record, :create?

      if record.save
        render(
          json: ProjectSerializer.new(record).as_json
        )
      else
        render(
          json:   {
            message: record.errors.full_messages
          },
          status: :unprocessable_entity
        )
      end
    end
  end
end
