# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WitnessesManager::Base, type: :service do
  let(:project) { create(:project, witnesses_number: 3) }
  let(:expected_witness) { project.witnesses.first }
  let(:siglum) { expected_witness.siglum }
  let(:params) { {} }
  let(:service) { described_class.new(project:, siglum:, params:) }

  describe '#initialize' do
    context 'when witness with given siglum can be found' do
      it 'sets the @witness' do
        expect(service.instance_variable_get('@witness')).to eq(expected_witness)
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
    it 'raises NotImplementedError by default' do
      expect { service.perform! }.to raise_error(NotImplementedError)
    end
  end

  describe 'self.perform!' do
    let(:instance_mock) { instance_double(described_class) }

    before do
      allow(described_class).to receive(:new).and_return(instance_mock)
      allow(instance_mock).to receive(:perform!)
      described_class.perform!(project:, siglum:, params:)
    end

    it 'initializes new instance with given options' do
      expect(described_class).to have_received(:new).with(project:, siglum:, params:)
    end

    it 'runs perform! on the new instance' do
      expect(instance_mock).to have_received(:perform!)
    end
  end
end
