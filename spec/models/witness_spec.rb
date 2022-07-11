# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Witness, type: :model do
  describe '#validations' do
    subject(:token) { described_class.new }

    it { is_expected.to validate_presence_of(:siglum) }
    it { is_expected.to validate_length_of(:name).is_at_most(50).allow_blank }
  end

  describe 'factories' do
    it 'creates valid default factory' do
      expect(build(:witness)).to be_valid
    end
  end

  describe '#as_json' do
    let(:witness) { build(:witness, :with_project) }

    let(:expected_result) do
      witness.attributes.merge({ id: witness.id, default: witness.default? }).as_json
    end

    it 'returns attributes hash and the :id' do
      expect(witness.as_json).to eq(expected_result)
    end
  end

  describe 'default!' do
    let(:default_witness) { 'A' }
    let(:project) { build(:project, witnesses_number: 3, default_witness:) }
    let(:witness) { project.witnesses.last }

    before { witness.default! }

    it 'is now default' do
      expect(witness).to be_default
    end

    it 'updates the default_witness of the project to witness\'s siglum' do
      expect(project.default_witness).to eq(witness.siglum)
    end
  end

  describe 'not_default!' do
    let(:default_witness) { 'A' }
    let(:project) { build(:project, witnesses_number: 3, default_witness:) }

    before { witness.not_default! }

    context 'when witness was project default' do
      let(:witness) { project.witnesses.first }

      it 'is no longer default' do
        expect(witness).not_to be_default
      end

      it 'clears default_witness of the project' do
        expect(project.default_witness).to be_nil
      end
    end

    context 'when witness was not project default' do
      let(:witness) { project.witnesses.last }

      it 'is not default' do
        expect(witness).not_to be_default
      end

      it 'does not change default_witness of the project' do
        expect(project.default_witness).to eq(default_witness)
      end
    end
  end

  describe 'handle_default!' do
    let(:witness) { build(:witness) }

    before do
      allow(witness).to receive(:default!)
      allow(witness).to receive(:not_default!)
      witness.handle_default!(default_value)
    end

    context 'when the given value is true' do
      let(:default_value) { true }

      it 'runs witness.default!' do
        expect(witness).to have_received(:default!)
      end
    end

    context 'when the given value is false' do
      let(:default_value) { false }

      it 'runs witness.not_default!!' do
        expect(witness).to have_received(:not_default!)
      end
    end
  end
end
