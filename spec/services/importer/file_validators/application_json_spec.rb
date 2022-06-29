# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Importer::FileValidators::ApplicationJson, type: :service do
  let(:project) { create(:project, :with_json_source_file) }
  let(:service) { described_class.new(project:) }

  describe '#validate' do
    let(:result) { service.validate }

    context 'when valid standard file' do
      it 'returns success' do
        expect(result).to be_success
      end

      it 'returns empty errors' do
        expect(result.errors).to be_empty
      end
    end

    context 'when valid simplified file' do
      let(:project) { create(:project, :with_simplified_json_source_file) }

      it 'returns success' do
        expect(result).to be_success
      end

      it 'returns empty errors' do
        expect(result.errors).to be_empty
      end
    end

    context 'when invalid file' do
      let(:project) { create(:project) }

      before do
        project.source_file.attach(
          io:           File.open(Rails.root.join(data_path)),
          filename:     "#{rand}_project.json",
          content_type: 'application/json'
        )
      end

      context 'when an invalid JSON file' do
        let(:data_path) { 'spec/fixtures/invalid/invalid_json.json' }

        it 'assigns correct error' do
          expect(result.errors).to match_array([I18n.t('importer.errors.json_files.invalid_json')])
        end

        it 'is not successful' do
          expect(result).not_to be_success
        end
      end

      context 'when missing top keys' do
        let(:data_path) { 'spec/fixtures/invalid/missing_keys.json' }
        let(:expected_errors) do
          [
            I18n.t('importer.errors.json_files.missing_keys'),
            I18n.t('importer.errors.json_files.missing_witnesses')
          ]
        end

        it 'assigns correct error' do
          expect(result.errors).to match_array(expected_errors)
        end

        it 'is not successful' do
          expect(result).not_to be_success
        end
      end

      context 'when missing witnesses' do
        let(:data_path) { 'spec/fixtures/invalid/missing_witnesses.json' }

        it 'assigns correct error' do
          expect(result.errors).to match_array([I18n.t('importer.errors.json_files.missing_witnesses')])
        end

        it 'is not successful' do
          expect(result).not_to be_success
        end
      end

      context 'when number of tokens does not match witnesses' do
        let(:data_path) { 'spec/fixtures/invalid/missing_tokens.json' }

        it 'assigns correct error' do
          expect(result.errors).to match_array([I18n.t('importer.errors.json_files.incorrect_number_of_tokens')])
        end

        it 'is not successful' do
          expect(result).not_to be_success
        end
      end
    end
  end
end
