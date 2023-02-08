# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apparatus::Entry do
  describe 'factories' do
    it 'creates valid default factory' do
      expect(build(:apparatus_entry)).to be_valid
    end
  end

  describe '#attributes' do
    let(:record) { build(:apparatus_entry) }

    it 'includes correct keys' do
      expect(record.attributes.keys).to eq(%w[token_id index])
    end
  end

  describe '#value' do
    let(:record) { build(:apparatus_entry) }

    it 'is nil' do
      expect(record.value).to be_nil
    end
  end
end
