# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#validations' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:password) }
    it { is_expected.to validate_length_of(:password).is_at_least(8) }
    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_presence_of(:name) }
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
