# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Importer::Inserter, type: :service do
  let(:name) { 'project name' }
  let(:default_witness) { 'A' }
  let(:extracted_data) { build(:extracted_data) }
  let(:service) { described_class.new(name:, default_witness:, extracted_data:) }

  describe '#process' do
    it 'creates project' do
      expect { service.process }.to change(Project, :count).by(1)
    end

    context 'when project created' do
      before { service.process }

      it 'passes correct name to project' do
        expect(service.project.name).to eq(name)
      end

      it 'passes correct default_witness to project' do
        expect(service.project.default_witness).to eq(default_witness)
      end

      it 'passes correct witnesses to project' do
        expect(service.project.witnesses).to eq(extracted_data.witnesses)
      end
    end
  end
end
