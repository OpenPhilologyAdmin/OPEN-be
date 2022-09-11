# frozen_string_literal: true

require 'rails_helper'
require 'support/helpers/token_variants'

RSpec.configure do |c|
  c.include Helpers::TokenVariants
end

RSpec.describe TokensManager::Resizer::Builders::TokenFromValue, type: :service do
  let(:value) { Faker::Lorem.sentence }
  let(:project) { create(:project) }
  let(:service) { described_class.new(value:, project:) }

  describe '#perform' do
    let(:token) { service.perform }

    context 'when the given value does not include placeholders' do
      it 'builds variants with the given value' do
        token.variants.each do |variant|
          expect(variant.t).to eq(value)
        end
      end

      it 'builds variants for the given witnesses IDs' do
        expect(token.variants.size).to eq(project.witnesses_ids.size)
        token.variants.each do |variant|
          expect(project.witnesses_ids).to include(variant.witness)
        end
      end

      it 'leaves editorial_remark as nil' do
        expect(token.editorial_remark).to be_nil
      end

      it 'generates the grouped variants with the default generator' do
        expect(token.grouped_variants).to eq(generate_grouped_variants(token:))
      end
    end

    context 'when the given value does include placeholders' do
      let(:placeholder) {  FormattableT::EMPTY_VALUE_PLACEHOLDER }
      let(:value) { "Lorem #{placeholder} ipsum#{placeholder}" }
      let(:expected_t) { 'Lorem  ipsum' }

      it 'builds variants with the given value without placeholders' do
        token.variants.each do |variant|
          expect(variant.t).to eq(expected_t)
        end
      end

      it 'builds variants for the given witnesses IDs' do
        expect(token.variants.size).to eq(project.witnesses_ids.size)
        token.variants.each do |variant|
          expect(project.witnesses_ids).to include(variant.witness)
        end
      end

      it 'leaves editorial_remark as nil' do
        expect(token.editorial_remark).to be_nil
      end

      it 'generates the grouped variants with the default generator' do
        expect(token.grouped_variants).to eq(generate_grouped_variants(token:))
      end
    end
  end
end
