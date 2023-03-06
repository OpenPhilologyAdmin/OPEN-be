# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Exporter::Models::ExportErrors, type: :model do
  describe '#errors' do
    let(:resource) { described_class.new(apparatus_options:) }

    context 'when there are errors on the apparatus options' do
      let(:apparatus_options) { build(:apparatus_options, :invalid) }

      it 'equals the errors_hash from apparatus' do
        expect(resource.errors).to eq(apparatus_options.errors_hash)
      end
    end
  end
end
