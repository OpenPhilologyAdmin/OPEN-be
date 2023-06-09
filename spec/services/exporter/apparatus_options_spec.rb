# frozen_string_literal: true

require 'rails_helper'
require 'support/shared_examples/has_full_message_errors_hash'

RSpec.describe Exporter::ApparatusOptions, type: :model do
  describe '#validations' do
    subject(:resource) { build(:apparatus_options) }

    let(:allowed_boolean_values) { [true, false, 'true', 'false', '1', '0'] }
    let(:forbidden_values_for_string_fields) { described_class::FORBIDDEN_VALUES }

    it { is_expected.to allow_value(allowed_boolean_values).for(:footnote_numbering) }
    it { is_expected.not_to allow_value(nil).for(:footnote_numbering) }
    it { is_expected.to allow_value(allowed_boolean_values).for(:significant_readings) }
    it { is_expected.not_to allow_value(nil).for(:significant_readings) }
    it { is_expected.to allow_value(allowed_boolean_values).for(:insignificant_readings) }
    it { is_expected.not_to allow_value(nil).for(:insignificant_readings) }
    it { is_expected.to validate_presence_of(:selected_reading_separator) }
    it { is_expected.to validate_presence_of(:readings_separator) }
    it { is_expected.to validate_length_of(:selected_reading_separator).is_at_most(1) }
    it { is_expected.to validate_length_of(:readings_separator).is_at_most(1) }
    it { is_expected.to validate_length_of(:sigla_separator).is_at_most(1) }

    it 'does not allow setting any of the forbidden values for :selected_reading_separator' do
      forbidden_values_for_string_fields.each do |forbidden_value|
        expect(resource).not_to allow_value(forbidden_value).for(:selected_reading_separator)
      end
    end

    it 'does not allow setting any of the forbidden values for :readings_separator' do
      forbidden_values_for_string_fields.each do |forbidden_value|
        expect(resource).not_to allow_value(forbidden_value).for(:readings_separator)
      end
    end

    it 'does not allow setting any of the forbidden values for :sigla_separator' do
      forbidden_values_for_string_fields.each do |forbidden_value|
        expect(resource).not_to allow_value(forbidden_value).for(:sigla_separator)
      end
    end
  end

  describe 'factories' do
    it 'creates valid default factory' do
      expect(build(:apparatus_options)).to be_valid
    end
  end

  describe '#footnote_numbering?' do
    context 'when footnote_numbering is truthy' do
      it 'is truthy' do
        expect(build(:apparatus_options, footnote_numbering: true)).to be_footnote_numbering
      end
    end

    context 'when footnote_numbering is falsey' do
      it 'is falsey' do
        expect(build(:apparatus_options, footnote_numbering: false)).not_to be_footnote_numbering
      end
    end
  end

  describe '#significant_readings?' do
    context 'when significant_readings is truthy' do
      it 'is truthy' do
        expect(build(:apparatus_options, significant_readings: true)).to be_significant_readings
      end
    end

    context 'when significant_readings is falsey' do
      it 'is falsey' do
        expect(build(:apparatus_options, significant_readings: false)).not_to be_significant_readings
      end
    end
  end

  describe '#insignificant_readings?' do
    context 'when insignificant_readings is truthy' do
      it 'is truthy' do
        expect(build(:apparatus_options, insignificant_readings: true)).to be_insignificant_readings
      end
    end

    context 'when insignificant_readings is falsey' do
      it 'is falsey' do
        expect(build(:apparatus_options, insignificant_readings: false)).not_to be_insignificant_readings
      end
    end
  end

  describe '#include_apparatus?' do
    context 'when both significant_readings and insignificant_readings are falsey' do
      let(:resource) do
        build(:apparatus_options, significant_readings: false, insignificant_readings: false)
      end

      it 'is falsey' do
        expect(resource).not_to be_include_apparatus
      end
    end

    context 'when significant_readings are truthy and insignificant_readings are falsey' do
      let(:resource) do
        build(:apparatus_options, significant_readings: true, insignificant_readings: false)
      end

      it 'is truthy' do
        expect(resource).to be_include_apparatus
      end
    end

    context 'when significant_readings are falsey and insignificant_readings are truthy' do
      let(:resource) do
        build(:apparatus_options, significant_readings: false, insignificant_readings: true)
      end

      it 'is truthy' do
        expect(resource).to be_include_apparatus
      end
    end
  end

  it_behaves_like 'resource with full message errors hash' do
    let(:resource) { build(:apparatus_options, :invalid) }
  end
end
