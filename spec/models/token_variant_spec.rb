# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TokenVariant, type: :model do
  describe 'factories' do
    it 'creates valid default factory' do
      expect(build(:token_variant)).to be_valid
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
end
