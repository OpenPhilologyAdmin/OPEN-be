# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apparatus::InsignificantEntry, type: :model do
  describe 'factories' do
    it 'creates valid default factory' do
      expect(build(:apparatus_insignificant_entry)).to be_valid
    end

    it 'creates valid :variant_selected factory' do
      expect(build(:apparatus_insignificant_entry, :variant_selected)).to be_valid
    end
  end

  describe '#value' do
    context 'when there is no variant selected' do
      let(:record) { build(:apparatus_insignificant_entry) }

      it 'is nil' do
        expect(record.value).to be_nil
      end
    end

    context 'when there there is a variant selected' do
      let(:record) { build(:apparatus_insignificant_entry, :variant_selected) }
      let(:expected_reading) do
        record.insignificant_variants.map do |v|
          "#{v.t.strip} #{v.witnesses.join(' ')}"
        end.join(', ')
      end

      it 'includes the reading for all insignificant variants' do
        expect(record.value).to eq(expected_reading)
      end
    end
  end
end
