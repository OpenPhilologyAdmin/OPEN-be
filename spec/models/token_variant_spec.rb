# frozen_string_literal: true

require 'rails_helper'
require 'support/shared_examples/formattable_t'

RSpec.describe TokenVariant, type: :model do
  describe 'factories' do
    it 'creates valid default factory' do
      expect(build(:token_variant)).to be_valid
    end
  end

  describe '#validations' do
    subject(:token_variant) { build(:token_variant) }

    context 'when parent(token) is present' do
      let(:token) { create(:token) }

      before { token_variant.parent = token }

      it { is_expected.to validate_inclusion_of(:witness).in_array(token.project_witnesses_ids) }
    end

    context 'when parent(token) is not present' do
      before { token_variant.parent = nil }

      it 'is valid' do
        expect(token_variant).to be_valid
      end
    end
  end

  describe '#for_witness?' do
    let(:siglum) { 'A' }

    context 'when the variant is for the given witness' do
      let(:token_variant) { build(:token_variant, witness: siglum) }

      it 'is true' do
        expect(token_variant).to be_for_witness(siglum)
      end
    end

    context 'when the variant is not for the given witness' do
      let(:token_variant) { build(:token_variant, witness: 'B') }

      it 'is falsey' do
        expect(token_variant).not_to be_for_witness(siglum)
      end
    end
  end

  it_behaves_like 'formattable t' do
    let(:resource) { build(:token_variant) }
  end
end
