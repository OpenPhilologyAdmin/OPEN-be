# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EditedTokensEvaluator, type: :service do
  let(:project) { create(:project) }
  let(:selected_token_ids) { [selected_token1.id, selected_token2.id, selected_token3.id] }

  let(:service) { described_class.new(project:, selected_token_ids:) }

  describe '#perform' do
    let(:result) { service.perform }

    context 'when there are no comments, editorial remarks, or selected variants' do
      let(:selected_token1) { create(:token, :without_editorial_remark, project:, index: 0) }
      let(:selected_token2) { create(:token, :without_editorial_remark, project:, index: 1) }
      let(:selected_token3) { create(:token, :without_editorial_remark, project:, index: 2) }

      it 'returns false for comments' do
        expect(result[:comments]).to be_falsey
      end

      it 'returns false for editorial_remarks' do
        expect(result[:editorial_remarks]).to be_falsey
      end

      it 'returns false for variants_selections' do
        expect(result[:variants_selections]).to be_falsey
      end
    end

    context 'when there are no editorial remarks and selected variants, but there are comments' do
      let(:selected_token1) { create(:token, :without_editorial_remark, project:, index: 0) }
      let(:selected_token2) { create(:token, :without_editorial_remark, project:, index: 1) }
      let(:selected_token3) { create(:token, :without_editorial_remark, project:, index: 2) }

      before { create(:comment, token: selected_token2) }

      it 'returns true for comments' do
        expect(result[:comments]).to be_truthy
      end

      it 'returns false for editorial_remarks' do
        expect(result[:editorial_remarks]).to be_falsey
      end

      it 'returns false for variants_selections' do
        expect(result[:variants_selections]).to be_falsey
      end
    end

    context 'when there are no comments and selected variants, but there is editorial remark' do
      let(:selected_token1) { create(:token, project:, index: 0) }
      let(:selected_token2) { create(:token, :without_editorial_remark, project:, index: 1) }
      let(:selected_token3) { create(:token, :without_editorial_remark, project:, index: 2) }

      it 'returns false for comments' do
        expect(result[:comments]).to be_falsey
      end

      it 'returns true for editorial_remarks' do
        expect(result[:editorial_remarks]).to be_truthy
      end

      it 'returns false for variants_selections' do
        expect(result[:variants_selections]).to be_falsey
      end
    end

    context 'when there are no comments, editorial remarks, but there are selected variants' do
      let(:selected_token1) { create(:token, :without_editorial_remark, project:, index: 0) }
      let(:selected_token2) { create(:token, :without_editorial_remark, project:, index: 1) }
      let(:selected_token3) { create(:token, :without_editorial_remark, :variant_selected, project:, index: 2) }

      it 'returns false for comments' do
        expect(result[:comments]).to be_falsey
      end

      it 'returns false for editorial_remarks' do
        expect(result[:editorial_remarks]).to be_falsey
      end

      it 'returns true for variants_selections' do
        expect(result[:variants_selections]).to be_truthy
      end
    end

    context 'when there are comments, editorial remarks and selected variants' do
      let(:selected_token1) { create(:token, project:, index: 0) }
      let(:selected_token2) { create(:token, :variant_selected, project:, index: 1) }
      let(:selected_token3) { create(:token, :without_editorial_remark, project:, index: 2) }

      before { create(:comment, token: selected_token3) }

      it 'returns true for comments' do
        expect(result[:comments]).to be_truthy
      end

      it 'returns true for editorial_remarks' do
        expect(result[:editorial_remarks]).to be_truthy
      end

      it 'returns true for variants_selections' do
        expect(result[:variants_selections]).to be_truthy
      end
    end
  end
end
