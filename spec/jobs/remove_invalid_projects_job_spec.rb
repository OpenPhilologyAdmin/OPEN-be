# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RemoveInvalidProjectsJob, type: :job do
  let(:old_invalid_project) do
    create(:project, :status_invalid, created_at: (described_class::DELAY.ago - 1.day))
  end
  let(:invalid_project) do
    create(:project, :status_invalid, created_at: (described_class::DELAY.ago + 1.day))
  end
  let(:old_processed_project) do
    create(:project, :status_processed, created_at: (described_class::DELAY.ago - 1.day))
  end

  before do
    old_invalid_project
    invalid_project
    old_processed_project
  end

  it 'deletes invalid files older than given time period' do
    expect { described_class.perform_now }.to change { Project.all.size }.by(-1)
  end

  it 'does not delete projects with :processed status' do
    described_class.perform_now
    expect(old_processed_project.reload).to be_persisted
  end

  it 'does not delete new invalid projects projects' do
    described_class.perform_now
    expect(invalid_project.reload).to be_persisted
  end
end
