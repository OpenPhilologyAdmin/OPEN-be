# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TokenGroupedVariant, type: :model do
  describe 'factories' do
    it 'creates valid default factory' do
      expect(build(:token_grouped_variant)).to be_valid
    end
  end

  describe '#for_witness?' do
    let(:siglum) { 'A' }

    context 'when witnesses array include given siglum' do
      let(:token_grouped_variant) { build(:token_grouped_variant, witnesses: [siglum, 'B']) }

      it 'is true' do
        expect(token_grouped_variant).to be_for_witness(siglum)
      end
    end

    context 'when witnesses array does not include given siglum' do
      let(:token_grouped_variant) { build(:token_grouped_variant, witnesses: ['B']) }

      it 'is falsey' do
        expect(token_grouped_variant).not_to be_for_witness(siglum)
      end
    end
  end
end
