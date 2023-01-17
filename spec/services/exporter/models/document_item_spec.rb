# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Exporter::Models::DocumentItem, type: :model do
  describe '#to_export' do
    let(:resource) { described_class.new }

    it 'raises NotImplementedError' do
      expect { resource.to_export }.to raise_error(NotImplementedError)
    end
  end
end
