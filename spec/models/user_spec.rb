# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#validations' do
    subject(:user) { described_class.new }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:password) }
    it { is_expected.to validate_length_of(:password).is_at_least(8) }
    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_presence_of(:name) }

    context 'when password is present' do
      context 'when password contains both letters and numbers' do
        it 'is valid' do
          expect(user).to allow_value(Faker::Lorem.characters(number: 8, min_alpha: 1, min_numeric: 1)).for(:password)
        end
      end

      context 'when password contains only letters or only numbers' do
        it { is_expected.not_to allow_value(Faker::Alphanumeric.alpha(number: 8)).for(:password) }
        it { is_expected.not_to allow_value(Faker::Number.number(digits: 8)).for(:password) }
      end
    end
  end

  describe 'factories' do
    it 'creates valid default factory' do
      expect(build(:user)).to be_valid
    end

    it 'creates valid admin factory' do
      expect(build(:user, :admin)).to be_valid
    end
  end
end