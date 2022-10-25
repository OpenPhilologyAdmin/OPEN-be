# frozen_string_literal: true

module EditTrackerHelper
  def update_last_editor(user:)
    project.update(last_editor: user)
  end

  def update_last_edited_project(project:)
    user.update(last_edited_project: project)
  end
end
