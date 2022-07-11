# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WitnessesManager::Updater, type: :service do
  let(:project) { create(:project, witnesses_number: 3, default_witness: 'A') }
  let(:previous_default_witness) { project.witnesses.first }
  let(:edited_witness) { project.witnesses.last }
  let(:siglum) { edited_witness.siglum }
  let(:params) { { name: 'New name', default: true } }
  let(:service) { described_class.new(project:, siglum:, params:) }

  describe '#initialize' do
    context 'when witness with given siglum can be found' do
      it 'sets the @witness' do
        expect(service.instance_variable_get('@witness')).to eq(edited_witness)
      end
    end

    context 'when witness with given siglum cannot be found' do
      let(:siglum) { 'not-existing-siglum' }

      it 'raises ActiveRecord::RecordNotFound' do
        expect { service }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when params[:default] it truthy' do
      let(:params) { { name: 'New name', default: ['1', true].sample } }

      it 'sets the @default_witness_value to truthy' do
        expect(service.instance_variable_get('@default_witness_value')).to be_truthy
      end
    end

    context 'when params[:default] is falsey' do
      let(:params) { { name: 'New name', default: ['0', false].sample } }

      it 'sets the @default_witness_value to falsey' do
        expect(service.instance_variable_get('@default_witness_value')).to be_falsey
      end
    end
  end

  describe '#perform!' do
    let!(:result) { described_class.perform!(project:, siglum:, params:) }

    context 'when the edited witness is the new default one' do
      it 'updates the edited witness with the given attributes' do
        params.each_pair do |key, value|
          expect(edited_witness.send(key)).to eq(value)
        end
      end

      it 'saves witness\'s siglum as a default_witness' do
        project.reload
        expect(project.default_witness).to eq(siglum)
      end

      it 'updates previous default witness not to be default' do
        expect(previous_default_witness).not_to be_default
      end

      it 'returns success result' do
        expect(result.success).to be_truthy
      end

      it 'returns edited witness in the result' do
        expect(result.witness).to eq(edited_witness)
      end
    end

    context 'when the edited witness is not set as default' do
      let(:params) { { name: 'New name' } }

      it 'updates the edited witness with the given attributes' do
        params.each_pair do |key, value|
          expect(edited_witness.send(key)).to eq(value)
        end
      end

      it 'does not update project\'s default_witness' do
        project.reload
        expect(project.default_witness).to eq(previous_default_witness.siglum)
      end

      it 'the previous default witness has still default: true' do
        expect(previous_default_witness).to be_default
      end

      it 'returns success result' do
        expect(result.success).to be_truthy
      end

      it 'returns edited witness in the result' do
        expect(result.witness).to eq(edited_witness)
      end
    end

    context 'when the edited witness was deselected from being the default one' do
      let(:params) { { name: 'New name', default: false } }
      let(:edited_witness) { previous_default_witness }
      let(:siglum) { previous_default_witness.siglum }

      it 'updates the edited witness with the given attributes' do
        params.each_pair do |key, value|
          expect(edited_witness.send(key)).to eq(value)
        end
      end

      it 'clears the project default witness' do
        project.reload
        expect(project.default_witness).to be_nil
      end

      it 'returns success result' do
        expect(result.success).to be_truthy
      end

      it 'returns edited witness in the result' do
        expect(result.witness).to eq(edited_witness)
      end
    end

    context 'when the edited witness is invalid' do
      let(:params) { { name: Faker::Lorem.characters(number: 60), default: true } }

      it 'assigns the given attributes to the edited witness' do
        params.each_pair do |key, value|
          expect(edited_witness.send(key)).to eq(value)
        end
      end

      it 'assigns errors to project' do
        expect(project).not_to be_valid
      end

      it 'does not update project\'s default_witness' do
        project.reload
        expect(project.default_witness).to eq(previous_default_witness.siglum)
      end

      it 'does not update previous default witness' do
        expect(previous_default_witness).to be_default
      end

      it 'returns result that is not a success' do
        expect(result.success).to be_falsey
      end

      it 'returns edited witness in the result' do
        expect(result.witness).to eq(edited_witness)
      end

      it 'returns the witness that is not valid' do
        expect(result.witness).not_to be_valid
      end

      it 'returns the witness that has errors' do
        expect(result.witness.errors).not_to be_empty
      end
    end
  end
end
