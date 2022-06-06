# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Importer::Base, type: :service do
  let(:data_path) { 'spec/fixtures/sample_project.txt' }
  let(:service) { described_class.new(data_path:) }

  describe '#initialize' do
    it 'sets the data_path' do
      expect(service.instance_variable_get('@data_path')).to eq(Rails.root.join(data_path))
    end

    it 'initializes errors hash' do
      expect(service.instance_variable_get('@errors')).to eq({})
    end
  end

  describe '#validate_file_format' do
    before do
      service.send(:validate_file_format)
    end

    context 'when file format is allowed' do
      it 'the service is valid' do
        expect(service).to be_valid
      end
    end

    context 'when file format is not allowed' do
      let(:data_path) { 'spec/fixtures/sample_project.csv' }

      it 'the service is no longer valid' do
        expect(service).not_to be_valid
      end

      it 'assigns errors to service' do
        expect(service.errors[:file]).to eq(I18n.t('importer.errors.invalid_file_format'))
      end
    end
  end
end
