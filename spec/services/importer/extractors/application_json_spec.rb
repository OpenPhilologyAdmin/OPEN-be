# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'extracting data from JSON file' do
  it 'returns Importer::ExtractedData model' do
    expect(result).to be_a(Importer::ExtractedData)
  end

  it 'returns correct number of tokens' do
    expect(result.tokens.size).to eq(expected_number_of_tokens)
  end

  it 'generates correct token when variants differ' do
    expect(result.tokens[expected_token.index].as_json)
      .to eq(expected_token.as_json)
  end

  it 'generates correct token when variants are the same' do
    expect(result.tokens[expected_token_grouped_variants.index].as_json)
      .to eq(expected_token_grouped_variants.as_json)
  end

  it 'generates correct token when one of variants values is empty' do
    expect(result.tokens[expected_token_empty_variant.index].as_json)
      .to eq(expected_token_empty_variant.as_json)
  end

  it 'returns correct witnesses' do
    expect(result.witnesses.as_json).to eq(expected_witnesses.as_json)
  end
end

RSpec.describe Importer::Extractors::ApplicationJson, type: :service do
  let(:project) { create(:project, :with_json_source_file) }
  let(:service) { described_class.new(project:) }
  let(:default_witness) { project.default_witness }

  describe '#process' do
    let(:expected_number_of_tokens) { 3 }
    let(:expected_witnesses) do
      [
        build(:witness,
              siglum: 'A',
              name:   nil),
        build(:witness,
              siglum: 'B',
              name:   nil)
      ]
    end
    let(:expected_token) do
      build(:token,
            index:            0,
            project:,
            variants:         [
              build(:token_variant,
                    witness:  'A',
                    t:        'Lorem',
                    selected: false,
                    possible: false,
                    deleted:  false),

              build(:token_variant,
                    witness:  'B',
                    t:        'Lorum',
                    selected: false,
                    possible: false,
                    deleted:  false)
            ],
            grouped_variants: [
              build(:token_grouped_variant,
                    t:         'Lorem',
                    witnesses: ['A'],
                    selected:  false,
                    possible:  false),
              build(:token_grouped_variant,
                    t:         'Lorum',
                    witnesses: ['B'],
                    selected:  false,
                    possible:  false)
            ])
    end
    let(:expected_token_grouped_variants) do
      build(:token,
            index:            1,
            project:,
            variants:         [
              build(:token_variant,
                    witness:  'A',
                    t:        'ipsum',
                    selected: false,
                    possible: false,
                    deleted:  false),

              build(:token_variant,
                    witness:  'B',
                    t:        'ipsum',
                    selected: false,
                    possible: false,
                    deleted:  false)
            ],
            grouped_variants: [
              build(:token_grouped_variant,
                    t:         'ipsum',
                    witnesses: %w[A B],
                    selected:  false,
                    possible:  false)
            ])
    end
    let(:expected_token_empty_variant) do
      build(:token,
            index:            2,
            project:,
            variants:         [
              build(:token_variant,
                    witness:  'A',
                    t:        'dolor',
                    selected: false,
                    possible: false,
                    deleted:  false),

              build(:token_variant,
                    witness:  'B',
                    t:        described_class::EMPTY_VARIANT_VALUE,
                    selected: false,
                    possible: false,
                    deleted:  false)
            ],
            grouped_variants: [
              build(:token_grouped_variant,
                    t:         'dolor',
                    witnesses: ['A'],
                    selected:  false,
                    possible:  false),
              build(:token_grouped_variant,
                    t:         described_class::EMPTY_VARIANT_VALUE,
                    witnesses: ['B'],
                    selected:  false,
                    possible:  false)
            ])
    end

    let(:result) { service.process }

    context 'when standard JSON format' do
      let(:project) { create(:project, :with_json_source_file) }

      include_examples 'extracting data from JSON file'
    end

    context 'when simplified JSON format' do
      let(:project) { create(:project, :with_simplified_json_source_file) }

      include_examples 'extracting data from JSON file'
    end
  end
end
