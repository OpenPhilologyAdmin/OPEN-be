# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Exporter::Models::Stylers::Rtf, type: :model do
  describe '#perform' do
    let(:resource) { described_class.new }
    let(:value) { Faker::Lorem.word }

    context 'when style: superscript' do
      it 'returns the value inside correct styling tags' do
        expect(resource.perform(value:, style: :superscript)).to eq("{\\super #{value}}")
      end
    end

    context 'when style: bold' do
      it 'returns the value inside correct styling tags' do
        expect(resource.perform(value:, style: :bold)).to eq("{\\b #{value}}")
      end
    end

    context 'when style: paragraph' do
      it 'returns the value inside correct styling tags' do
        expect(resource.perform(value:, style: :paragraph)).to eq("{\\par #{value} \\par}")
      end
    end
  end
end
