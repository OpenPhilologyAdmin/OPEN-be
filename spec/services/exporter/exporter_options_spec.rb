# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Exporter::ExporterOptions, type: :model do
  describe '#validations' do
    subject(:resource) { build(:exporter_options) }

    let(:allowed_boolean_values) { [true, false, 'true', 'false', '1', '0'] }

    it { is_expected.to allow_value(allowed_boolean_values).for(:footnote_numbering) }
    it { is_expected.not_to allow_value(nil).for(:footnote_numbering) }
    it { is_expected.to validate_inclusion_of(:layout).in_array(described_class::LAYOUTS) }
    it { is_expected.to validate_presence_of(:layout) }
  end

  describe 'factories' do
    it 'creates valid default factory' do
      expect(build(:exporter_options)).to be_valid
    end
  end

  describe '#footnote_numbering?' do
    context 'when footnote_numbering is truthy' do
      it 'is truthy' do
        expect(build(:exporter_options, footnote_numbering: true)).to be_footnote_numbering
      end
    end

    context 'when footnote_numbering is falsey' do
      it 'is falsey' do
        expect(build(:exporter_options, footnote_numbering: false)).not_to be_footnote_numbering
      end
    end
  end
end
