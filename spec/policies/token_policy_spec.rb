# frozen_string_literal: true

require 'rails_helper'

describe TokenPolicy do
  subject(:record_policy) { described_class }

  permissions :index?, :show?,
              :update_variants?, :update_grouped_variants?,
              :resize?, :edited?,
              :significant_variants?, :insignificant_variants? do
    context 'when logged in admin' do
      context 'when admin is approved' do
        let(:current_user) { build(:user, :admin, :approved) }

        it 'grants access' do
          expect(record_policy).to permit(current_user, build(:token))
        end
      end

      context 'when admin is not approved' do
        let(:current_user) { build(:user, :admin, :not_approved) }

        it 'denies access' do
          expect(record_policy).not_to permit(current_user, build(:token))
        end
      end
    end

    context 'when not logged in' do
      let(:current_user) { nil }

      it 'denies access' do
        expect(record_policy).not_to permit(current_user, build(:token))
      end
    end
  end

  permissions :create?, :new?, :edit?, :destroy? do
    context 'when logged in admin' do
      context 'when admin is approved' do
        let(:current_user) { build(:user, :admin, :approved) }

        it 'denies access' do
          expect(record_policy).not_to permit(current_user, build(:token))
        end
      end

      context 'when admin is not approved' do
        let(:current_user) { build(:user, :admin, :not_approved) }

        it 'denies access' do
          expect(record_policy).not_to permit(current_user, build(:token))
        end
      end
    end

    context 'when not logged in' do
      let(:current_user) { nil }

      it 'denies access' do
        expect(record_policy).not_to permit(current_user, build(:token))
      end
    end
  end

  describe 'policy_scope' do
    let(:current_user) { build(:user, :admin, :approved) }

    context 'when user has created some projects' do
      let(:created_project) { create(:project, :with_creator, creator: current_user) }
      let(:created_project2) { create(:project, :with_creator, creator: current_user) }
      let(:created_project_token) { create(:token, project: created_project) }
      let(:created_project2_token) { create(:token, project: created_project2) }
      let(:other_user_project) { create(:project, :with_creator) }

      before do
        created_project_token
        create(:token, project: other_user_project)
        created_project2_token
      end

      it 'returns only created projects' do
        expect(Pundit.policy_scope(current_user, Token.all)).to(
          contain_exactly(created_project_token, created_project2_token)
        )
      end
    end

    context 'when user has not created any projects yet' do
      let(:other_user_project) { create(:project, :with_creator) }

      before do
        create(:token, project: other_user_project)
        create(:token)
      end

      it 'returns empty array' do
        expect(Pundit.policy_scope(current_user, Token.all)).to be_empty
      end
    end
  end
end
