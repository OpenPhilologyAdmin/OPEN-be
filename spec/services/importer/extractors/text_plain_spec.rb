# frozen_string_literal: true

# rubocop:disable RSpec/MultipleMemoizedHelpers
#
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
    let(:expected_result) do
      [
        [expected_index, expected_variants, expected_grouped_variants]
      ]
    end

    it 'returns the whole file content as an only token' do
      expect(service.process).to eq(expected_result)
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
