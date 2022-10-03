# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WitnessesManager::Creator::TokensProcessor, type: :service do
  let(:service) { described_class.new(tokens:, siglum:) }
  let(:project) { create(:project, witnesses_number: 3) }
  let(:siglum) { 'new-witness-siglum' }
  let(:tokens) { project.tokens }
  let(:expected_witnesses_number) { 4 }

  before do
    create_list(:token, 3, project:)
    project.witnesses << Witness.new(siglum:)
  end

  describe '#add_witness' do
    it 'does not change number of tokens in general' do
      expect { service.add_witness }.not_to(change { Token.all.size })
    end

    it 'does not change number of tokens for the project' do
      expect { service.add_witness }.not_to(change { project.tokens.size })
    end

    context 'when processing tokens' do
      before do
        tokens.each do |token|
          token.grouped_variants << TokenGroupedVariant.new(t:         token.current_variant.t,
                                                            witnesses: ['nice-witness'],
                                                            selected:  false,
                                                            possible:  false)
        end

        service.add_witness
        tokens.each(&:reload)
      end

      it 'adds the witness to the tokens\'s variants' do
        tokens.each do |token|
          expect(token.variants.size).to eq(expected_witnesses_number)
          expect(token.variants.map(&:witness)).to include(siglum)
        end
      end

      it 'adds the witness to the tokens\'s grouped_variants' do
        tokens.each do |token|
          expect(token.grouped_variants.find { |record| record.for_witness?(siglum) }).not_to be_blank
        end
      end
    end
  end
end
