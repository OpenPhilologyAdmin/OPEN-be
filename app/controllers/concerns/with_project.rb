# frozen_string_literal: true

module WithProject
  extend ActiveSupport::Concern

  included do
    before_action :fetch_project
  end

  private

  def fetch_project
    @project = Project.find(params[:project_id])
  end
end
