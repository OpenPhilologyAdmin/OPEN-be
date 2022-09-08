# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TokensResizer::Processor, type: :service do
  let(:project) { create(:project) }
  let(:user) { create(:user, :approved, :admin) }
  let(:service) do
    described_class.new(project:, user:, selected_text:, selected_token_ids:)
  end

  describe '#perform' do
    let(:selected_token) { create(:token, :one_grouped_variant, project:, index: 0) }
    let(:selected_text) { selected_token.t[1...-1].to_s }
    let(:selected_token_ids) { [selected_token.id] }
    let(:expected_nr_of_tokens) { 8 }

    before do
      selected_token
      1.upto(5) do |index|
        create(:token, project:, index:)
      end
      service.perform
      project.reload
    end

    it 'saves the user as the last editor of the project' do
      expect(project.last_editor).to eq(user)
    end

    it 'removes the selected tokens' do
      expect(Token.where(id: selected_token.id)).to be_empty
    end

    it 'creates correct number of new tokens' do
      expect(project.tokens.size).to eq(expected_nr_of_tokens)
    end

    it 'ensures token indexes are correct' do
      expect(project.tokens.pluck(:index)).to match_array(0.upto(expected_nr_of_tokens - 1))
    end

    it 'saves the text before the selected_text as a first token' do
      expect(project.tokens.first.t).to eq(selected_token.t[0...1])
    end

    it 'saves the selected_text as second token' do
      expect(project.tokens.second.t).to eq(selected_text)
    end

    it 'saves the text after the selected_text as a third token' do
      expect(project.tokens.third.t).to eq(selected_token.t[-1...])
    end
  end
end
