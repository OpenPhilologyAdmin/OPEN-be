# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Importer::Base, type: :service do
  let(:data_path) { 'spec/fixtures/sample_project.txt' }
  let(:name) { 'project name' }
  let(:default_witness) { 'A' }
  let(:service) { described_class.new(data_path:, name:, default_witness:) }

  describe '#initialize' do
    it 'sets the data_path' do
      expect(service.instance_variable_get('@data_path')).to eq(Rails.root.join(data_path))
    end

    it 'sets the default_witness' do
      expect(service.instance_variable_get('@default_witness')).to eq(default_witness)
    end

    it 'sets the name' do
      expect(service.instance_variable_get('@name')).to eq(name)
    end

    it 'initializes the errors hash' do
      expect(service.instance_variable_get('@errors')).to eq({})
    end
  end

  describe '#perform_validations' do
    before do
      service.perform_validations
    end

    context 'when file format is allowed' do
      it 'the service is valid' do
        expect(service).to be_valid
      end
    end

    context 'when file format is not allowed' do
      let(:data_path) { 'spec/fixtures/sample_project.csv' }

      it 'the service is not valid' do
        expect(service).not_to be_valid
      end

      it 'assigns errors to service' do
        expect(service.errors[:file]).to eq(I18n.t('importer.errors.invalid_file_format'))
      end
    end
  end

  describe '#valid?' do
    context 'when there are no errors assigned' do
      it 'is valid' do
        expect(service).to be_valid
      end
    end

    context 'when there are some errors assigned' do
      it 'is not valid' do
        service.add_error(:base, 'error message')
        expect(service).not_to be_valid
      end
    end
  end

  describe '#add_error' do
    let(:error_key) { :base }
    let(:error_message) { 'error message' }

    it 'assigns error with given details' do
      service.add_error(error_key, error_message)
      expect(service.errors[error_key]).to eq(error_message)
    end
  end

  describe '#extractor' do
    let(:extractor) { service.send(:extractor) }

    it 'initializes correct extractor for given file type' do
      expect(extractor.class).to eq(Importer::Extractors::TextPlain)
    end

    it 'passes the data_path to extractor' do
      expect(extractor.instance_variable_get('@data_path')).to eq(Rails.root.join(data_path))
    end

    it 'passes the default_witness to extractor' do
      expect(extractor.instance_variable_get('@default_witness')).to eq(default_witness)
    end
  end

  describe '#mime_type' do
    it 'recognizes mime_type from file' do
      expect(service.send(:mime_type)).to eq('text/plain')
    end
  end

  describe '#process' do
    let(:extractor) { service.send(:extractor) }

    before do
      allow(service).to receive(:perform_validations)
      allow(service).to receive(:valid?).and_return(validation_result)
      allow(extractor).to receive(:process)
      service.process
    end

    context 'when validation returned some errors' do
      let(:validation_result) { false }

      it 'does not run the extractor' do
        expect(extractor).not_to have_received(:process)
      end
    end

    context 'when validation did not return any errors' do
      let(:validation_result) { true }

      it 'runs the extractor' do
        expect(extractor).to have_received(:process)
      end
    end
  end
end
