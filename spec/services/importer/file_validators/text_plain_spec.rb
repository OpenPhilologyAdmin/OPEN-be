# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Importer::FileValidators::TextPlain, type: :service do
  let(:project) { create(:project, :with_source_file) }
  let(:service) { described_class.new(project:) }

  describe '#validate' do
    let(:result) { service.validate }

    it 'always returns success' do
      expect(result).to be_success
    end

    it 'returns empty errors' do
      expect(result.errors).to be_empty
    end
  end
end
