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

      context 'when password contains letters, numbers, and special chars' do
        it 'is valid' do
          passwords = ['fp3ef.YnK2rQ*-_L!', 'XnX2Do!erTr@N3n2', 'Dh4cm8FsN_YFD*of_']
          passwords.each do |password|
            expect(user).to allow_value(password).for(:password)
          end
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

    it 'creates valid :admin factory' do
      expect(build(:user, :admin)).to be_valid
    end

    it 'creates valid :approved factory' do
      expect(build(:user, :approved)).to be_valid
    end

    it 'creates valid :not_approved factory' do
      expect(build(:user, :not_approved)).to be_valid
    end
  end

  describe '#account_approved?' do
    context 'when user not approved yet' do
      it 'is falsey' do
        expect(build(:user, :not_approved)).not_to be_account_approved
      end
    end

    context 'when user is approved' do
      it 'is truthy' do
        expect(build(:user, :approved)).to be_account_approved
      end
    end
  end

  describe '#approved_admin?' do
    context 'when admin user not approved yet' do
      it 'is falsey' do
        expect(build(:user, :admin, :not_approved)).not_to be_approved_admin
      end
    end

    context 'when admin user is approved' do
      it 'is truthy' do
        expect(build(:user, :admin, :approved)).to be_approved_admin
      end
    end
  end

  describe '#approve!' do
    let(:approval_result) { user.approve! }

    before do
      approval_result
      user.reload
    end

    context 'when user not approved yet' do
      let(:user) { create(:user, :not_approved) }

      it 'sets approved_at value' do
        expect(user).to be_account_approved
      end

      it 'returns true' do
        expect(approval_result).to be_truthy
      end
    end

    context 'when user has already been approved' do
      let(:previous_approved_at) { 1.month.ago }
      let(:user) { create(:user, approved_at: previous_approved_at) }

      it 'does not update approved_at value' do
        expect(user.approved_at).to be_within(1.second).of(previous_approved_at)
      end

      it 'returns false' do
        expect(approval_result).to be_falsey
      end
    end
  end
end
