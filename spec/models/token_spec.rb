# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Token, type: :model do
  describe '#validations' do
    subject(:token) { described_class.new }

    it { is_expected.to validate_presence_of(:index) }
    it { is_expected.to validate_presence_of(:variants) }
  end

  describe 'factories' do
    it 'creates valid default factory' do
      expect(build(:token)).to be_valid
    end
  end
end
