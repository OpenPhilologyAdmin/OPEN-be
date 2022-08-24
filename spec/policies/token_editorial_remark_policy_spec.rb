# frozen_string_literal: true

require 'rails_helper'

describe TokenEditorialRemarkPolicy do
  subject(:token_editorial_remark_policy) { described_class }

  permissions :index? do
    context 'when logged in as admin' do
      context 'when admin is approved' do
        let(:current_user) { build(:user, :admin, :approved) }

        it 'grants access' do
          expect(token_editorial_remark_policy).to permit(current_user, build(:token_editorial_remark))
        end
      end
    end

    context 'when admin is not approved' do
      let(:current_user) { build(:user, :admin, :not_approved) }

      it 'denies access' do
        expect(token_editorial_remark_policy).not_to permit(current_user, build(:token_editorial_remark))
      end
    end

    context 'when not logged in' do
      let(:current_user) { nil }

      it 'denies access' do
        expect(token_editorial_remark_policy).not_to permit(current_user, build(:token_editorial_remark))
      end
    end
  end
end
