# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TokensManager::Resizer::Result, type: :model do
  let(:params) do
    TokensManager::Resizer::Params.new(
      project:            nil,
      selected_token_ids: nil
    )
  end
  let(:resource) { described_class.new(success:, params:) }

  describe '#success?' do
    context 'when success is true' do
      let(:success) { true }

      it 'is truthy' do
        expect(resource).to be_success
      end
    end

    context 'when success is false' do
      let(:success) { false }

      it 'is falsey' do
        expect(resource).not_to be_success
      end
    end
  end
end
