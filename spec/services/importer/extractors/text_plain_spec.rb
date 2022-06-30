# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Importer::Extractors::TextPlain, type: :service do
  let(:project) { create(:project, :with_source_file) }
  let(:service) { described_class.new(project:, default_witness_name:) }
  let(:default_witness) { project.default_witness }
  let(:default_witness_name) { 'Witness name' }

  describe '#initialize' do
    it 'sets the project' do
      expect(service.project).to eq(project)
    end

    it 'opens the data file' do
      expect(service.source_file).to eq(project.source_file)
    end

    it 'sets the default_witness' do
      expect(service.default_witness).to eq(project.default_witness)
    end

    it 'initializes tokens array' do
      expect(service.instance_variable_get('@tokens')).to eq([])
    end
  end
  # rubocop:disable RSpec/MultipleMemoizedHelpers

  describe '#process' do
    let(:file_content) { project.source_file.open(&:read) }
    let(:expected_index) { described_class::STARTING_INDEX }
    let(:expected_variants) do
      [
        build(:token_variant,
              witness:  default_witness,
              t:        file_content,
              selected: false,
              deleted:  false)
      ]
    end
    let(:expected_grouped_variants) do
      [
        build(:token_grouped_variant,
              t:         file_content,
              witnesses: [default_witness],
              selected:  false)
      ]
    end
    let(:expected_witness) do
      build(:witness,
            siglum: default_witness,
            name:   default_witness_name)
    end
    let(:expected_token) do
      build(:token,
            index:            expected_index,
            project:,
            variants:         expected_variants,
            grouped_variants: expected_grouped_variants)
    end
    let(:expected_result) do
      build(:extracted_data,
            tokens:    [expected_token],
            witnesses: [expected_witness])
    end

    let(:result) { service.process }

    it 'returns Importer::ExtractedData model' do
      expect(result).to be_a(Importer::ExtractedData)
    end

    it 'returns correct tokens - one token with the whole file content' do
      expect(result.tokens.as_json).to eq(expected_result.tokens.as_json)
    end

    it 'returns correct witnesses - just one default witness' do
      expect(result.witnesses.as_json).to eq(expected_result.witnesses.as_json)
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers
end
