# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Importer::Extractors::TextPlain, type: :service do
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
    let(:file_content) { File.read(data_path) }
    let(:expected_index) { described_class::STARTING_INDEX }
    let(:expected_variants) do
      [
        [
          {
            witness:  default_witness,
            t:        file_content,
            selected: false,
            deleted:  false
          }
        ]
      ]
    end
    let(:expected_grouped_variants) do
      [
        {
          t:         file_content,
          witnesses: [default_witness],
          selected:  false
        }
      ]
    end
    let(:expected_witness) do
      {
        siglum: default_witness,
        name:   nil
      }
    end

    let(:expected_result) do
      build(:extracted_data,
            tokens:    [
              [expected_index, expected_variants, expected_grouped_variants]
            ],
            witnesses: [expected_witness])
    end

    let(:result) { service.process }

    it 'returns Importer::Extractors::Models::ExtractedData model' do
      expect(result).to be_a(Importer::Extractors::Models::ExtractedData)
    end

    it 'returns correct tokens - one token with the whole file content' do
      expect(result.tokens).to eq(expected_result.tokens)
    end

    it 'returns correct witnesses - just one default witness' do
      expect(result.witnesses).to eq(expected_result.witnesses)
    end
  end
end
