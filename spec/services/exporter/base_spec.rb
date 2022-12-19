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
        Exporter::Models::Token.new(
          value:              token1.t,
          footnote_numbering: false,
          index:              nil
        ),
        Exporter::Models::Token.new(
          value:              token2.t,
          footnote_numbering: true,
          index:              1
        )
      ]
    end
    let(:expected_apparatuses) do
      [
        Exporter::Models::Apparatus.new(
          selected_variant:       token2.selected_variant,
          secondary_variants:     token2.secondary_variants,
          insignificant_variants: token2.insignificant_variants,
          apparatus_options:,
          index:                  1
        )
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

      it 'prepares a document' do
        expect(result).to be_an_instance_of(Exporter::Models::Document)
      end

      it 'assigns two paragraphs to the document' do
        expect(result.paragraphs.size).to eq(2)
      end

      it 'adds the tokens to the first paragraph with the correct styling' do
        paragraph        = result.paragraphs.first
        expected_content = build(:exporter_paragraph, contents: expected_exporter_tokens)
        expect(paragraph.to_export).to eq(expected_content.to_export)
      end

      it 'adds the apparatuses to the second paragraph with the correct styling' do
        paragraph        = result.paragraphs.second
        expected_content = build(:exporter_paragraph, contents: expected_apparatuses)
        expect(paragraph.to_export).to eq(expected_content.to_export)
      end
    end
  end
end
