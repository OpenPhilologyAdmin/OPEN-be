# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EditTrackerHelper do
  let(:user) { create(:user, :admin, :approved) }
  let(:project) { create(:project) }

  describe '#update_last_editor' do
    it 'updates last editor' do
      expect(lambda {
        helper.update_last_editor(user:)
      }).to(change(project, :last_editor)).to { user.id }
    end
  end

  describe '#update_last_edited_project' do
    it 'updates last edited project' do
      expect(lambda {
        helper.update_last_edited_project(project:)
      }).to(change(user, :last_edited_project)).to { project.id }
    end
  end
end
