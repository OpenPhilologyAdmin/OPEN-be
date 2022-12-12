# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EditTrackerHelper do
  let(:user) { create(:user, :admin, :approved) }
  let(:project) { create(:project) }

  describe '#update_last_editor' do
    it 'updates last editor' do
      helper.update_last_editor(user:, project:)
      expect(project.last_editor).to eq(user)
    end
  end

  describe '#update_last_edited_project' do
    it 'updates last edited project' do
      helper.update_last_edited_project(project:, user:)
      expect(user.last_edited_project).to eq(project)
    end
  end
end
