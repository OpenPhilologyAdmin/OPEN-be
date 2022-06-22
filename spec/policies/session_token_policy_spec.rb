# frozen_string_literal: true

require 'rails_helper'

describe SessionTokenPolicy do
  subject(:record_policy) { described_class }

  permissions :create? do
    context 'when logged in admin' do
      context 'when admin is approved' do
        let(:current_user) { build(:user, :admin, :approved) }

        it 'grants access' do
          expect(record_policy).to permit(current_user)
        end
      end

      context 'when admin is not approved' do
        let(:current_user) { build(:user, :admin, :not_approved) }

        it 'denies access' do
          expect(record_policy).not_to permit(current_user)
        end
      end
    end

    context 'when not logged in' do
      let(:current_user) { nil }

      it 'denies access' do
        expect(record_policy).not_to permit(current_user)
      end
    end
  end

  permissions :index?, :new?, :show?, :update?, :edit?, :destroy? do
    context 'when logged in admin' do
      context 'when admin is approved' do
        let(:current_user) { build(:user, :admin, :approved) }

        it 'denies access' do
          expect(record_policy).not_to permit(current_user)
        end
      end

      context 'when admin is not approved' do
        let(:current_user) { build(:user, :admin, :not_approved) }

        it 'denies access' do
          expect(record_policy).not_to permit(current_user)
        end
      end
    end

    context 'when not logged in' do
      let(:current_user) { nil }

      it 'denies access' do
        expect(record_policy).not_to permit(current_user)
      end
    end
  end
end
