# frozen_string_literal: true

require 'rails_helper'

describe ProjectPolicy do
  subject(:record_policy) { described_class }

  permissions :create?, :index? do
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

  permissions :update?, :show?, :export?, :manage_witnesses?,
              :index_witnesses?, :create_witnesses?, :update_witnesses? do
    context 'when logged in admin' do
      context 'when admin is approved' do
        let(:current_user) { build(:user, :admin, :approved) }

        context 'when created the project' do
          it 'grants access' do
            expect(record_policy).to permit(current_user, create(:project, :with_creator, creator: current_user))
          end
        end

        context 'when did not create the project' do
          it 'grants access' do
            expect(record_policy).not_to permit(current_user, build(:project))
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
          context 'when created the project' do
            let(:project) { create(:project, :with_creator, creator: current_user, witnesses_number: 3) }

            it 'grants access' do
              expect(record_policy).to permit(current_user, project)
            end
          end

          context 'when did not create the project' do
            let(:project) { create(:project, witnesses_number: 3) }

            it 'denies access' do
              expect(record_policy).not_to permit(current_user, project)
            end
          end
        end

        context 'when there is just one witnesses' do
          context 'when created the project' do
            let(:project) { create(:project, :with_creator, creator: current_user, witnesses_number: 1) }

            it 'denies access' do
              expect(record_policy).not_to permit(current_user, project)
            end
          end

          context 'when did not create the project' do
            let(:project) { create(:project, witnesses_number: 1) }

            it 'denies access' do
              expect(record_policy).not_to permit(current_user, project)
            end
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

  permissions :new?, :edit? do
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

  describe 'policy_scope' do
    let(:current_user) { build(:user, :admin, :approved) }

    context 'when user has created some projects' do
      let(:created_project) { create(:project, :with_creator, creator: current_user) }
      let(:created_project2) { create(:project, :with_creator, creator: current_user) }
      let(:other_user_project) { create(:project, :with_creator) }

      before do
        created_project
        other_user_project
        created_project2
      end

      it 'returns only created projects' do
        expect(Pundit.policy_scope(current_user, Project.all)).to(
          contain_exactly(created_project, created_project2)
        )
      end
    end

    context 'when user has not created any projects yet' do
      let(:other_user_project) { create(:project, :with_creator) }

      before do
        other_user_project
      end

      it 'returns empty array' do
        expect(Pundit.policy_scope(current_user, Project.all)).to be_empty
      end
    end
  end
end
