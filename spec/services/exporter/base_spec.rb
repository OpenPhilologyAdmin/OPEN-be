# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Exporter::Base, type: :service do
  let(:project) { create(:project) }
  let(:options) do
    attributes_for(:apparatus_options).merge(
      attributes_for(:exporter_options)
    )
  end

  let(:service) { described_class.new(project:, options:) }

  describe '#initialize' do
    it 'sets the @project' do
      expect(service.instance_variable_get('@project')).to eq(project)
    end

    it 'sets the @exporter_options' do
      exporter_options = service.instance_variable_get('@exporter_options')
      expect(exporter_options).to be_an_instance_of(Exporter::ExporterOptions)
    end

    it 'passes :footnote_numbering to the @exporter_options' do
      exporter_options = service.instance_variable_get('@exporter_options')
      expect(exporter_options.footnote_numbering).to eq(options[:footnote_numbering])
    end

    it 'passes :layout to the @exporter_options' do
      exporter_options = service.instance_variable_get('@exporter_options')
      expect(exporter_options.layout).to eq(options[:layout])
    end

    it 'sets the @apparatus_options' do
      apparatus_options = service.instance_variable_get('@apparatus_options')
      expect(apparatus_options).to be_an_instance_of(Exporter::ApparatusOptions)
    end

    it 'passes :significant_readings to the @apparatus_options' do
      apparatus_options = service.instance_variable_get('@apparatus_options')
      expect(apparatus_options.significant_readings).to eq(options[:significant_readings])
    end

    it 'passes :insignificant_readings to the @apparatus_options' do
      apparatus_options = service.instance_variable_get('@apparatus_options')
      expect(apparatus_options.insignificant_readings).to eq(options[:insignificant_readings])
    end

    it 'passes :selected_reading_separator to the @apparatus_options' do
      apparatus_options = service.instance_variable_get('@apparatus_options')
      expect(apparatus_options.selected_reading_separator).to eq(options[:selected_reading_separator])
    end

    it 'passes :secondary_readings_separator to the @apparatus_options' do
      apparatus_options = service.instance_variable_get('@apparatus_options')
      expect(apparatus_options.secondary_readings_separator).to eq(options[:secondary_readings_separator])
    end

    it 'passes :insignificant_readings_separator to the @apparatus_options' do
      apparatus_options = service.instance_variable_get('@apparatus_options')
      expect(apparatus_options.insignificant_readings_separator).to eq(options[:insignificant_readings_separator])
    end

    it 'passes :entries_separator to the @apparatus_options' do
      apparatus_options = service.instance_variable_get('@apparatus_options')
      expect(apparatus_options.entries_separator).to eq(options[:entries_separator])
    end
  end

  describe '#perform' do
    let(:result) { service.perform }
    let(:token1) { create(:token, project:, index: 1) }
    let(:token2) { create(:token, :variant_selected_and_secondary, project:, index: 2) }
    let(:expected_exporter_tokens) do
      [
        build(:exporter_token,
              value:                 token1.t,
              footnote_numbering:    false,
              apparatus_entry_index: nil),
        build(:exporter_token,
              value:                 token2.t,
              footnote_numbering:    true,
              apparatus_entry_index: 1)
      ]
    end
    let(:expected_apparatuses) do
      [
        build(:exporter_apparatus,
              selected_variant:       token2.selected_variant,
              secondary_variants:     token2.secondary_variants,
              insignificant_variants: token2.insignificant_variants,
              apparatus_options:,
              index:                  1)
      ]
    end

    before do
      token1
      token2
    end

    context 'when given options valid' do
      let(:apparatus_options) do
        build(:apparatus_options,
              significant_readings:             options[:significant_readings],
              insignificant_readings:           options[:insignificant_readings],
              selected_reading_separator:       options[:selected_reading_separator],
              secondary_readings_separator:     options[:secondary_readings_separator],
              insignificant_readings_separator: options[:insignificant_readings_separator],
              entries_separator:                options[:entries_separator])
      end
      let(:expected_paragraphs) do
        [
          build(:exporter_paragraph, contents: expected_exporter_tokens),
          build(:exporter_paragraph, contents: expected_apparatuses)
        ]
      end

      it 'returns success: true result' do
        expect(result).to be_success
      end

      it 'returns a correct document.to_export' do
        expected_result_document = Exporter::Models::Document.new(paragraphs: expected_paragraphs)
        expect(result.data).to eq(expected_result_document.to_export)
      end
    end

    context 'when given options invalid' do
      let(:options) do
        attributes_for(:apparatus_options, :invalid).merge(
          attributes_for(:exporter_options, :invalid)
        )
      end
      let(:expected_errors) do
        build(:apparatus_options, :invalid).errors_hash.merge(
          build(:exporter_options, :invalid).errors_hash
        )
      end

      it 'returns success: false result' do
        expect(result).not_to be_success
      end

      it 'prepares correct errors' do
        expect(result.errors).to eq(expected_errors)
      end

      it 'does not prepare data' do
        expect(result.data).to be_nil
      end
    end
  end
end
