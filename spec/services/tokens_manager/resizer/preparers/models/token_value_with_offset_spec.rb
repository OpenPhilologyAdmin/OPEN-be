# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TokensManager::Resizer::Preparers::Models::TokenValueWithOffset, type: :model do
  describe '#initialize' do
    let(:offset) { 2 }
    let(:token) { create(:token) }
    let(:record) { described_class.new(offset:, token:) }

    it 'sets given offset' do
      expect(record.offset).to eq(offset)
    end

    it 'sets given token index as token_index' do
      expect(record.token_index).to eq(token.index)
    end

    it 'sets given token t as token_value' do
      expect(record.send(:token_value)).to eq(token.t)
    end
  end

  describe '#value_before' do
    let(:token) { create(:token) }
    let(:token_value) { token.t }
    let(:record) { described_class.new(offset:, token:) }

    context 'when given offset is 0' do
      let(:offset) { 0 }

      it 'returns empty string' do
        expect(record.value_before).to be_empty
      end
    end

    context 'when given offset is different than 0' do
      let(:offset) { 2 }

      it 'calculates correct value' do
        expect(record.value_before).to eq(token_value[0..1])
      end
    end
  end

  describe '#value_after' do
    let(:token) { create(:token) }
    let(:token_value) { token.t }
    let(:record) { described_class.new(offset:, token:) }

    context 'when given offset is the same as token_value length' do
      let(:offset) { token_value.length }

      it 'returns empty string' do
        expect(record.value_after).to be_empty
      end
    end

    context 'when given offset is different than token_value length' do
      let(:offset) { token_value.length - 2 }

      it 'calculates correct value' do
        expect(record.value_after).to eq(token_value[-2..])
      end
    end
  end
end