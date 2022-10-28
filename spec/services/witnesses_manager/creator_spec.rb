# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WitnessesManager::Creator, type: :service do
  let(:project) { create(:project) }
  let(:user) { create(:user, :admin, :approved) }
  let(:siglum) { 'new-witness-siglum' }
  let(:params) do
    {
      name:   'New name',
      siglum:
    }
  end
  let(:service) { described_class.new(project:, user:, params:) }
  let(:witness) { project.witnesses.find { |witness| witness.siglum == siglum } }

  describe '#perform' do
    let(:result) { described_class.perform(project:, user:, params:) }
    let(:tokens_processor_mock) { instance_double(described_class::TokensProcessor) }

    before do
      allow(described_class::TokensProcessor).to receive(:new).and_return(tokens_processor_mock)
      allow(tokens_processor_mock).to receive(:add_witness)
      result
    end

    context 'when the new witness is valid' do
      before { project.reload }

      it 'adds new witness to the project' do
        expect(witness).not_to be_blank
      end

      it 'assigns the given attributes to the new witness' do
        params.each_pair do |key, value|
          expect(witness.send(key)).to eq(value)
        end
      end

      it 'returns success result' do
        expect(result.success).to be_truthy
      end

      it 'returns the new witness in the result' do
        expect(result.witness).to eq(witness)
      end

      it 'updates the user as the last editor of project' do
        expect(project.last_editor).to eq(user)
      end

      it 'updates project as the last edited project by user' do
        expect(user.last_edited_project).to eq(project)
      end

      it 'runs TokensProcessor' do
        expect(described_class::TokensProcessor).to have_received(:new).with(
          tokens: project.tokens,
          siglum:
        )
        expect(tokens_processor_mock).to have_received(:add_witness)
      end
    end

    context 'when the edited witness is invalid' do
      let(:siglum) { '' }

      it 'assigns the given attributes to the new witness' do
        params.each_pair do |key, value|
          expect(witness.send(key)).to eq(value)
        end
      end

      it 'assigns errors to project' do
        expect(project).not_to be_valid
      end

      it 'returns the result that is not a success' do
        expect(result.success).to be_falsey
      end

      it 'returns the new witness in the result' do
        expect(result.witness).to eq(witness)
      end

      it 'returns the witness that is not valid' do
        expect(result.witness).not_to be_valid
      end

      it 'does not run TokensProcessor' do
        expect(described_class::TokensProcessor).not_to have_received(:new)
        expect(tokens_processor_mock).not_to have_received(:add_witness)
      end
    end
  end
end
