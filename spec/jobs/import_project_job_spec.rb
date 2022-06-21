# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImportProjectJob, type: :job do
  context 'when resources can be found' do
    let(:project) { create(:project) }
    let(:user) { create(:user) }
    let(:importer_mock) { instance_double(Importer::Base) }

    before do
      allow(Importer::Base).to receive(:new).and_return(importer_mock)
      allow(importer_mock).to receive(:process)

      described_class.perform_now(project.id, user.id)
    end

    it 'imports contents of the file' do
      expect(Importer::Base).to have_received(:new).with(project:, user:)
      expect(importer_mock).to have_received(:process)
    end
  end

  context 'when resources cannot be found' do
    it 'skips performing the job' do
      expect do
        described_class.perform_now('invalid-id', 'invalid-id')
      end.not_to raise_error
    end
  end
end
