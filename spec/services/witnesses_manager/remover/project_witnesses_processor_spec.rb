# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WitnessesManager::Remover::ProjectWitnessesProcessor, type: :service do
  let(:service) { described_class.new(project:, siglum:) }
  let(:project) { create(:project, witnesses_number: 3) }
  let(:siglum) { removed_witness.siglum }

  describe '#remove_witness!' do
    before do
      service.remove_witness!
      project.reload
    end

    context 'when the removed witness was not a default witness' do
      let!(:previous_default_witness) { project.default_witness }
      let(:removed_witness) { project.witnesses.last }

      it 'removes the witness from witnesses array' do
        expect(project.witnesses).not_to include(removed_witness)
      end

      it 'does not change the default_witness' do
        expect(project.default_witness).to eq(previous_default_witness)
      end
    end

    context 'when the removed witness was the default witness' do
      let(:removed_witness) { project.witnesses.first }

      it 'removes the witness from witnesses array' do
        expect(project.witnesses).not_to include(removed_witness)
      end

      it 'changes the default_witness' do
        expect(project.default_witness).not_to eq(siglum)
      end

      it 'sets the default_witness to correct value' do
        expected_new_default_witness = project.witnesses.find(&:default?)
        expect(project.default_witness).to eq(expected_new_default_witness.siglum)
      end

      it 'ensures that new default witness has default: true' do
        expected_new_default_witness = project.find_witness!(project.default_witness)

        expect(expected_new_default_witness).to be_default
      end
    end
  end
end
