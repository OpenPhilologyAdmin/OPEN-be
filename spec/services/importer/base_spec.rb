# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Importer::Base, type: :service do
  let(:project) { create(:project, :with_source_file) }
  let(:user) { create(:user) }
  let(:service) { described_class.new(project:, user:) }

  describe '#initialize' do
    it 'sets the project' do
      expect(service.instance_variable_get('@project')).to eq(project)
    end

    it 'sets the user' do
      expect(service.instance_variable_get('@user')).to eq(user)
    end

    it 'initializes the errors hash' do
      expect(service.instance_variable_get('@errors')).to eq({})
    end
  end

  describe '#perform_validations' do
    before do
      service.perform_validations
    end

    context 'when file is valid' do
      it 'the service is valid' do
        expect(service).to be_valid
      end
    end

    context 'when file is missing' do
      let(:project) { create(:project, source_file: nil) }

      it 'the service is not valid' do
        expect(service).not_to be_valid
      end

      it 'assigns errors to service' do
        expect(service.errors[:file]).to eq(I18n.t('importer.errors.missing_file'))
      end
    end
  end

  describe '#valid?' do
    context 'when there are no errors assigned' do
      it 'is valid' do
        expect(service).to be_valid
      end
    end

    context 'when there are some errors assigned' do
      it 'is not valid' do
        service.add_error(:base, 'error message')
        expect(service).not_to be_valid
      end
    end
  end

  describe '#add_error' do
    let(:error_key) { :base }
    let(:error_message) { 'error message' }

    it 'assigns error with given details' do
      service.add_error(error_key, error_message)
      expect(service.errors[error_key]).to eq(error_message)
    end

    it 'updates project status to :invalid' do
      service.add_error(error_key, error_message)
      expect(project.reload.status).to eq(:invalid)
    end
  end

  describe '#extractor' do
    let(:extractor) { service.send(:extractor) }

    it 'initializes correct extractor for given file type' do
      expect(extractor.class).to eq(Importer::Extractors::TextPlain)
    end

    it 'passes the project to extractor' do
      expect(extractor.instance_variable_get('@project')).to eq(project)
    end
  end

  describe '#mime_type' do
    it 'recognizes mime_type from file' do
      expect(service.send(:mime_type)).to eq('text/plain')
    end
  end

  describe '#process' do
    let(:extractor) { service.send(:extractor) }

    before do
      allow(service).to receive(:perform_validations)
    end

    context 'when file format is supported' do
      before do
        allow(service).to receive(:valid?).and_return(validation_result)
        allow(extractor).to receive(:process)
        service.process
      end

      context 'when validation returned some errors' do
        let(:validation_result) { false }

        it 'does not run the extractor' do
          expect(extractor).not_to have_received(:process)
        end

        it 'saves the user as project owner' do
          project_role = project.project_roles.last
          expect(project_role.user).to eq(user)
          expect(project_role.role).to eq(:owner)
        end
      end

      context 'when validation did not return any errors' do
        let(:validation_result) { true }

        it 'runs the extractor' do
          expect(extractor).to have_received(:process)
        end

        it 'saves the user as project owner' do
          project_role = project.project_roles.last
          expect(project_role.user).to eq(user)
          expect(project_role.role).to eq(:owner)
        end
      end
    end

    context 'when file format is not supported' do
      let(:project) { create(:project) }
      let(:data_path) { 'spec/fixtures/sample_project.csv' }

      before do
        project.source_file.attach(
          io:           File.open(Rails.root.join(data_path)),
          filename:     "#{rand}_project.csv",
          content_type: 'text/csv'
        )
        service.process
      end

      it 'the service is not valid' do
        expect(service).not_to be_valid
      end

      it 'assigns errors to service' do
        expect(service.errors[:file]).to eq(I18n.t('importer.errors.unsupported_file_format'))
      end

      it 'updates project status to :invalid' do
        expect(project.reload.status).to eq(:invalid)
      end

      it 'saves the user as project owner' do
        project_role = project.project_roles.last
        expect(project_role.user).to eq(user)
        expect(project_role.role).to eq(:owner)
      end
    end
  end
end
