# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Exporter::Models::Result, type: :model do
  let(:resource) { described_class.new(success:) }

  describe '#success?' do
    context 'when success is true' do
      let(:success) { true }

      it 'is truthy' do
        expect(resource).to be_success
      end
    end

    context 'when success is false' do
      let(:success) { false }

      it 'is falsey' do
        expect(resource).not_to be_success
      end
    end
  end
end
