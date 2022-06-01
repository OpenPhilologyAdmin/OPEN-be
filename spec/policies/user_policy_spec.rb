# frozen_string_literal: true

describe UserPolicy do
  subject(:user_policy) { described_class }

  permissions :index? do
    context 'when logged in admin' do
      let(:current_user) { build(:user, :admin) }

      it 'grants access' do
        expect(user_policy).to permit(current_user, build(:user))
      end
    end

    context 'when not logged in' do
      let(:current_user) { nil }

      it 'denies access' do
        expect(user_policy).not_to permit(current_user, build(:user))
      end
    end
  end

  permissions :show?, :create?, :new?, :update?, :edit?, :destroy? do
    context 'when logged in admin' do
      let(:current_user) { build(:user, :admin) }

      it 'denies access' do
        expect(user_policy).not_to permit(current_user, build(:user))
      end
    end

    context 'when not logged in' do
      let(:current_user) { nil }

      it 'denies access' do
        expect(user_policy).not_to permit(current_user, build(:user))
      end
    end
  end
end
