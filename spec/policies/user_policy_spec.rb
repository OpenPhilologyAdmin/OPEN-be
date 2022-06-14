# frozen_string_literal: true

require 'rails_helper'

describe UserPolicy do
  subject(:record_policy) { described_class }

  permissions :index? do
    context 'when logged in admin' do
      context 'when admin is approved' do
        let(:current_user) { build(:user, :admin, :approved) }

        it 'grants access' do
          expect(record_policy).to permit(current_user, build(:user))
        end
      end

      context 'when admin is not approved' do
        let(:current_user) { build(:user, :admin, :not_approved) }

        it 'denies access' do
          expect(record_policy).not_to permit(current_user, build(:user))
        end
      end
    end

    context 'when not logged in' do
      let(:current_user) { nil }

      it 'denies access' do
        expect(record_policy).not_to permit(current_user, build(:user))
      end
    end
  end

  permissions :approve? do
    context 'when logged in admin' do
      context 'when admin is approved' do
        let(:current_user) { build(:user, :admin, :approved) }

        context 'when edited user is not approved' do
          it 'grants access' do
            expect(record_policy).to permit(current_user, build(:user, :not_approved))
          end
        end

        context 'when edited user has already been approved' do
          it 'grants access' do
            expect(record_policy).to permit(current_user, build(:user, :approved))
          end
        end
      end

      context 'when admin is not approved' do
        let(:current_user) { build(:user, :admin, :not_approved) }

        context 'when edited user is not approved' do
          it 'denies access' do
            expect(record_policy).not_to permit(current_user, build(:user, :not_approved))
          end
        end

        context 'when edited user has already been approved' do
          it 'denies access' do
            expect(record_policy).not_to permit(current_user, build(:user, :approved))
          end
        end
      end
    end

    context 'when not logged in' do
      let(:current_user) { nil }

      context 'when edited user is not approved' do
        it 'denies access' do
          expect(record_policy).not_to permit(current_user, build(:user, :not_approved))
        end
      end

      context 'when edited user has already been approved' do
        it 'denies access' do
          expect(record_policy).not_to permit(current_user, build(:user, :approved))
        end
      end
    end
  end

  permissions :create? do
    context 'when logged in admin' do
      context 'when admin is approved' do
        let(:current_user) { build(:user, :admin, :approved) }

        it 'denies access' do
          expect(record_policy).not_to permit(current_user, build(:user))
        end
      end

      context 'when admin is not approved' do
        let(:current_user) { build(:user, :admin, :not_approved) }

        it 'denies access' do
          expect(record_policy).not_to permit(current_user, build(:user))
        end
      end
    end

    context 'when not logged in' do
      let(:current_user) { nil }

      it 'grants access' do
        expect(record_policy).to permit(current_user, build(:user))
      end
    end
  end

  permissions :show?, :new?, :update?, :edit?, :destroy? do
    context 'when logged in admin' do
      context 'when admin is approved' do
        let(:current_user) { build(:user, :admin, :approved) }

        it 'denies access' do
          expect(record_policy).not_to permit(current_user, build(:user))
        end
      end

      context 'when admin is not approved' do
        let(:current_user) { build(:user, :admin, :not_approved) }

        it 'denies access' do
          expect(record_policy).not_to permit(current_user, build(:user))
        end
      end
    end

    context 'when not logged in' do
      let(:current_user) { nil }

      it 'denies access' do
        expect(record_policy).not_to permit(current_user, build(:user))
      end
    end
  end
end
