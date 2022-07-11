# frozen_string_literal: true

require 'rails_helper'

describe ProjectPolicy do
  subject(:record_policy) { described_class }

  permissions :create?, :show?, :index?, :manage_witnesses?, :index_witnesses?, :update_witnesses? do
    context 'when logged in admin' do
      context 'when admin is approved' do
        let(:current_user) { build(:user, :admin, :approved) }

        it 'grants access' do
          expect(record_policy).to permit(current_user, build(:project))
        end
      end

      context 'when admin is not approved' do
        let(:current_user) { build(:user, :admin, :not_approved) }

        it 'denies access' do
          expect(record_policy).not_to permit(current_user, build(:project))
        end
      end
    end

    context 'when not logged in' do
      let(:current_user) { nil }

      it 'denies access' do
        expect(record_policy).not_to permit(current_user, build(:project))
      end
    end
  end

  permissions :destroy? do
    context 'when logged in admin' do
      context 'when admin is approved' do
        let(:current_user) { build(:user, :admin, :approved) }

        context 'when admin is a creator of the project' do
          let(:project) { create(:project, :with_creator, creator: current_user) }

          it 'grants access' do
            expect(record_policy).to permit(current_user, project)
          end
        end

        context 'when admin is not a creator of the project' do
          let(:project) { create(:project, :with_creator) }

          it 'denies access' do
            expect(record_policy).not_to permit(current_user, project)
          end
        end
      end

      context 'when admin is not approved' do
        let(:current_user) { build(:user, :admin, :not_approved) }

        it 'denies access' do
          expect(record_policy).not_to permit(current_user, build(:project))
        end
      end
    end

    context 'when not logged in' do
      let(:current_user) { nil }

      it 'denies access' do
        expect(record_policy).not_to permit(current_user, build(:project))
      end
    end
  end

  permissions :destroy_witnesses? do
    context 'when logged in admin' do
      context 'when admin is approved' do
        let(:current_user) { build(:user, :admin, :approved) }

        context 'when there is more than one witness' do
          let(:project) { create(:project, witnesses_number: 3) }

          it 'grants access' do
            expect(record_policy).to permit(current_user, project)
          end
        end

        context 'when there is just one witnesses' do
          let(:project) { create(:project, witnesses_number: 1) }

          it 'denies access' do
            expect(record_policy).not_to permit(current_user, project)
          end
        end
      end

      context 'when admin is not approved' do
        let(:current_user) { build(:user, :admin, :not_approved) }

        it 'denies access' do
          expect(record_policy).not_to permit(current_user, build(:project))
        end
      end
    end

    context 'when not logged in' do
      let(:current_user) { nil }

      it 'denies access' do
        expect(record_policy).not_to permit(current_user, build(:project))
      end
    end
  end

  permissions :new?, :update?, :edit? do
    context 'when logged in admin' do
      context 'when admin is approved' do
        let(:current_user) { build(:user, :admin, :approved) }

        it 'denies access' do
          expect(record_policy).not_to permit(current_user, build(:project))
        end
      end

      context 'when admin is not approved' do
        let(:current_user) { build(:user, :admin, :not_approved) }

        it 'denies access' do
          expect(record_policy).not_to permit(current_user, build(:project))
        end
      end
    end

    context 'when not logged in' do
      let(:current_user) { nil }

      it 'denies access' do
        expect(record_policy).not_to permit(current_user, build(:project))
      end
    end
  end
end
