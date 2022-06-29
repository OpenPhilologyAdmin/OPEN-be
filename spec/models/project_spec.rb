# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Project, type: :model do
  describe '#validations' do
    subject(:project) { described_class.new }

    it { is_expected.to validate_presence_of(:name) }
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
end
