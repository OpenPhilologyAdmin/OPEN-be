# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Project, type: :model do
  describe '#validations' do
    subject(:project) { described_class.new }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(50) }
    it { is_expected.to validate_length_of(:default_witness_name).is_at_most(50).allow_blank }

    context 'when TXT source file' do
      subject(:project) { build(:project, :with_source_file) }

      it { is_expected.to validate_presence_of(:default_witness) }
    end

    context 'when JSON source file' do
      subject(:project) { build(:project, :with_json_source_file) }

      it { is_expected.not_to validate_presence_of(:default_witness) }
    end
  end

  describe 'factories' do
    it 'creates valid default factory' do
      expect(build(:project)).to be_valid
    end

    it 'creates valid :status_processing factory' do
      expect(build(:project, :status_processing)).to be_valid
    end

    it 'creates valid :status_processed factory' do
      expect(build(:project, :status_processed)).to be_valid
    end

    it 'creates valid :status_invalid factory' do
      expect(build(:project, :status_invalid)).to be_valid
    end

    it 'creates valid :with_source_file factory' do
      expect(build(:project, :with_source_file)).to be_valid
    end

    it 'creates valid :with_json_source_file factory' do
      expect(build(:project, :with_json_source_file)).to be_valid
    end

    it 'creates valid :with_simplified_json_source_file factory' do
      expect(build(:project, :with_simplified_json_source_file)).to be_valid
    end

    it 'creates valid :with_creator factory' do
      expect(build(:project, :with_creator)).to be_valid
    end
  end

  describe '#source_file_content_type' do
    context 'when there is no source file attached' do
      it 'is nil' do
        expect(build(:project).source_file_content_type).to be_nil
      end
    end

    context 'when there is source file attached' do
      it 'returns file content_type' do
        expect(build(:project, :with_source_file).source_file_content_type).to eq('text/plain')
      end
    end
  end

  describe '#invalidate!' do
    let(:project) { create(:project, :status_processing) }
    let(:import_errors) do
      {
        base: I18n.t('importer.errors.missing_file')
      }.stringify_keys
    end

    before do
      project.import_errors = import_errors
      project.invalidate!
      project.reload
    end

    it 'changes project status to :invalid' do
      expect(project.status).to be_invalid
    end

    it 'saves :import_errors as well' do
      expect(project.import_errors).to eq(import_errors)
    end
  end

  describe '#default_witness_required?' do
    context 'when TXT source file' do
      let(:project) { build(:project, :with_source_file) }

      it 'is truthy' do
        expect(project).to be_default_witness_required
      end
    end

    context 'when JSON source file' do
      let(:project) { build(:project, :with_json_source_file) }

      it 'is falsey' do
        expect(project).not_to be_default_witness_required
      end
    end
  end

  describe 'witnesses_count' do
    context 'when there are no witnesses at all' do
      it 'is 0' do
        expect(build(:project, witnesses: []).witnesses_count).to eq(0)
      end
    end

    context 'when there are some witnesses' do
      it 'returns number of witnesses' do
        expect(build(:project, witnesses: build_list(:witness, 2)).witnesses_count).to eq(2)
      end
    end
  end

  describe '#creator' do
    let(:project) { create(:project) }
    let(:owner) { create(:project_role, :owner, project:).user }

    before do
      create(:project_role)
      owner
      create(:project_role, :owner, project:)
    end

    it 'equals the first person who has been added as an owner' do
      expect(project.creator).to eq(owner)
    end
  end

  describe '#created_by' do
    let(:project) { create(:project) }

    context 'when there is an owner of project' do
      let!(:owner) { create(:project_role, :owner, project:).user }

      it 'equals the first person who has been added as an owner' do
        expect(project.created_by).to eq(owner.name)
      end
    end

    context 'when the owner is missing' do
      it 'is nil' do
        expect(project.created_by).to be_nil
      end
    end
  end

  describe '#creator_id' do
    let(:project) { create(:project) }

    context 'when there is an owner of project' do
      let!(:owner) { create(:project_role, :owner, project:).user }

      it 'equals the ID of first person who has been added as an owner' do
        expect(project.creator_id).to eq(owner.id)
      end
    end

    context 'when the owner is missing' do
      it 'is nil' do
        expect(project.creator_id).to be_nil
      end
    end
  end

  describe '#last_edit_by' do
    context 'when there is a user who edited the project' do
      let(:user) { create(:user, :admin, :approved) }
      let(:project) { create(:project, last_editor: user) }

      it 'equals the name of last_editor' do
        expect(project.last_edit_by).to eq(user.name)
      end
    end

    context 'when the project has not been edited yet' do
      let(:project) { create(:project, last_editor: nil) }

      it 'is nil' do
        expect(project.last_edit_by).to be_nil
      end
    end
  end

  describe '#find_witness!' do
    context 'when witness with given siglum can be found' do
      let(:project) { build(:project, default_witness: siglum) }
      let(:siglum) { 'A' }

      it 'returns matching witness' do
        result = project.find_witness!(siglum)
        expect(result).to be_a(Witness)
        expect(result.siglum).to eq(siglum)
      end
    end

    context 'when witness with given siglum cannot be found' do
      let(:project) { build(:project) }
      let(:siglum) { 'not-existing-siglum' }

      it 'raises ActiveRecord::RecordNotFound' do
        expect { project.find_witness!(siglum) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
