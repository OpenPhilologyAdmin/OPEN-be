# frozen_string_literal: true

require 'rails_helper'
require 'support/shared_examples/formattable_t'

RSpec.describe TokenGroupedVariant, type: :model do
  describe 'factories' do
    it 'creates valid default factory' do
      expect(build(:token_grouped_variant)).to be_valid
    end

    it 'creates valid :selected factory' do
      expect(build(:token_grouped_variant, :selected)).to be_valid
    end

    it 'creates valid :secondary factory' do
      expect(build(:token_grouped_variant, :secondary)).to be_valid
    end

    it 'creates valid :insignificant factory' do
      expect(build(:token_grouped_variant, :insignificant)).to be_valid
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

  describe '#secondary?' do
    context 'when it should be listed as a secondary variant' do
      let(:token_grouped_variant) { build(:token_grouped_variant, :secondary) }

      it 'is truthy' do
        expect(token_grouped_variant).to be_secondary
      end
    end

    context 'when it is a selected variant' do
      let(:token_grouped_variant) { build(:token_grouped_variant, :selected) }

      it 'is falsey' do
        expect(token_grouped_variant).not_to be_secondary
      end
    end

    context 'when it is an insignificant variant' do
      let(:token_grouped_variant) { build(:token_grouped_variant, :insignificant) }

      it 'is falsey' do
        expect(token_grouped_variant).not_to be_secondary
      end
    end
  end

  describe '#insignificant?' do
    context 'when it should be listed as a secondary variant' do
      let(:token_grouped_variant) { build(:token_grouped_variant, :secondary) }

      it 'is falsey' do
        expect(token_grouped_variant).not_to be_insignificant
      end
    end

    context 'when it is a selected variant' do
      let(:token_grouped_variant) { build(:token_grouped_variant, :selected) }

      it 'is falsey' do
        expect(token_grouped_variant).not_to be_insignificant
      end
    end

    context 'when it is an insignificant variant' do
      let(:token_grouped_variant) { build(:token_grouped_variant, :insignificant) }

      it 'is truthy' do
        expect(token_grouped_variant).to be_insignificant
      end
    end
  end

  describe '#id' do
    context 'when there is just one witness' do
      let(:token_grouped_variant) { build(:token_grouped_variant, witnesses_number: 1) }
      let(:expected_value) { token_grouped_variant.witnesses.first }

      it 'equals the witness' do
        expect(token_grouped_variant.id).to eq(expected_value)
      end
    end

    context 'when there are multiple witness' do
      let(:token_grouped_variant) { build(:token_grouped_variant, witnesses_number: 3) }
      let(:expected_value) { token_grouped_variant.witnesses.sort.join }

      it 'equals joined values of alpha ordered witnesses' do
        expect(token_grouped_variant.id).to eq(expected_value)
      end
    end
  end

  it_behaves_like 'formattable t' do
    let(:resource) { build(:token_grouped_variant) }
  end
end
