# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Importer::Extractors::Base, type: :service do
  let(:data_path) { Rails.root.join('spec/fixtures/sample_project.txt') }
  let(:default_witness) { 'A' }
  let(:service) { described_class.new(data_path:, default_witness:) }

  describe '#initialize' do
    it 'sets the data_path' do
      expect(service.instance_variable_get('@data_path')).to eq(data_path)
    end

    it 'opens the data file' do
      expect(service.instance_variable_get('@file')).to be_instance_of(File)
    end

    it 'sets the default_witness' do
      expect(service.instance_variable_get('@default_witness')).to eq(default_witness)
    end

    it 'initializes tokens array' do
      expect(service.instance_variable_get('@tokens')).to eq([])
    end
  end

  describe '#process' do
    it 'raises NotImplementedError by default' do
      expect { service.process }.to raise_error(NotImplementedError)
    end
  end
end
