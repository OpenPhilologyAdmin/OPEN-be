# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Exporter::Models::Styler, type: :model do
  describe '#perform' do
    let(:resource) { described_class.new }
    let(:value) { Faker::Lorem.word }

    context 'when style: superscript' do
      it 'raises NotImplementedError' do
        expect { resource.perform(value:, style: :superscript) }.to raise_error(NotImplementedError)
      end
    end

    context 'when style: bold' do
      it 'raises NotImplementedError' do
        expect { resource.perform(value:, style: :bold) }.to raise_error(NotImplementedError)
      end
    end

    context 'when style: paragraph' do
      it 'raises NotImplementedError' do
        expect { resource.perform(value:, style: :paragraph) }.to raise_error(NotImplementedError)
      end
    end

    context 'when style: document' do
      it 'raises NotImplementedError' do
        expect { resource.perform(value:, style: :document) }.to raise_error(NotImplementedError)
      end
    end
  end
end
