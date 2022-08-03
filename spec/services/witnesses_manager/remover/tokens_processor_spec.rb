# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WitnessesManager::Remover::TokensProcessor, type: :service do
  let(:service) { described_class.new(tokens:, siglum:) }
  let(:project) { create(:project, witnesses_number: 3) }
  let(:expected_witnesses_number) { 2 }
  let(:siglum) { project.default_witness }
  let(:tokens) { project.tokens }

  before do
    create_list(:token, 3, project:)
  end

  describe '#remove_witness!' do
    it 'does not change number of tokens in general' do
      expect { service.remove_witness! }.not_to(change { Token.all.size })
    end

    it 'does not change number of tokens for the project' do
      expect { service.remove_witness! }.not_to(change { project.tokens.size })
    end

    context 'when processing tokens' do
      before do
        service.remove_witness!
        tokens.each(&:reload)
      end

      it 'removes witness from the tokens\'s variants' do
        tokens.each do |token|
          expect(token.variants.size).to eq(expected_witnesses_number)
          expect(token.variants.map(&:witness)).not_to include(siglum)
        end
      end

      it 'removes witness from the tokens\'s grouped_variants' do
        tokens.each do |token|
          expect(token.grouped_variants.find { |record| record.for_witness?(siglum) }).to be_blank
        end
      end
    end
  end
end
