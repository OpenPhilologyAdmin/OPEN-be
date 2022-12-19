# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Exporter::Models::ExportErrors, type: :model do
  describe '#errors' do
    let(:resource) { described_class.new(exporter_options:, apparatus_options:) }

    context 'when there are only errors on the exporter options' do
      let(:exporter_options) { build(:exporter_options, :invalid) }
      let(:apparatus_options) { build(:apparatus_options) }

      it 'equals the errors_hash from exporter' do
        expect(resource.errors).to eq(exporter_options.errors_hash)
      end
    end

    context 'when there are only errors on the apparatus options' do
      let(:exporter_options) { build(:exporter_options) }
      let(:apparatus_options) { build(:apparatus_options, :invalid) }

      it 'equals the errors_hash from apparatus' do
        expect(resource.errors).to eq(apparatus_options.errors_hash)
      end
    end

    context 'when there are errors in both places' do
      let(:exporter_options) { build(:exporter_options, :invalid) }
      let(:apparatus_options) { build(:apparatus_options, :invalid) }

      it 'equals the merged errors_hash' do
        expected_errors = apparatus_options.errors_hash.merge(
          exporter_options.errors_hash
        )
        expect(resource.errors).to eq(expected_errors)
      end
    end
  end
end
