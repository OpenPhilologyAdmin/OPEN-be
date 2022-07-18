# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WitnessesManager::Remover, type: :service do
  let(:project) { create(:project, witnesses_number: 3) }
  let(:user) { create(:user, :admin, :approved) }
  let(:removed_witness) { project.witnesses.last }
  let(:siglum) { removed_witness.siglum }
  let(:service) { described_class.new(project:, siglum:, user:) }

  describe '#initialize' do
    context 'when witness with given siglum can be found' do
      it 'sets the @witness' do
        expect(service.instance_variable_get('@witness')).to eq(removed_witness)
      end
    end

    context 'when witness with given siglum cannot be found' do
      let(:siglum) { 'not-existing-siglum' }

      it 'raises ActiveRecord::RecordNotFound' do
        expect { service }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '#perform!' do
    let(:tokens_processor_mock) { instance_double(WitnessesManager::Remover::TokensProcessor) }
    let(:project_processor_mock) { instance_double(WitnessesManager::Remover::ProjectWitnessesProcessor) }

    before do
      allow(WitnessesManager::Remover::TokensProcessor).to receive(:new).and_return(tokens_processor_mock)
      allow(tokens_processor_mock).to receive(:remove_witness!)

      allow(WitnessesManager::Remover::ProjectWitnessesProcessor).to receive(:new).and_return(project_processor_mock)
      allow(project_processor_mock).to receive(:remove_witness!)

      described_class.perform!(project:, siglum:, user:)
    end

    it 'runs TokensProcessor' do
      expect(WitnessesManager::Remover::TokensProcessor).to have_received(:new).with(tokens: project.tokens,
                                                                                     siglum:)
      expect(tokens_processor_mock).to have_received(:remove_witness!)
    end

    it 'runs ProjectWitnessesProcessor' do
      expect(WitnessesManager::Remover::ProjectWitnessesProcessor).to have_received(:new).with(project:,
                                                                                               siglum:)
      expect(project_processor_mock).to have_received(:remove_witness!)
    end

    it 'saves the user as the last editor of project' do
      expect(project.last_editor).to eq(user)
    end
  end
end
