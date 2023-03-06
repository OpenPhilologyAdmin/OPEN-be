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
      it 'returns the value inside paragraph with the correct styling' do
        expect(resource.perform(value:, style: :paragraph))
          .to eq("{\\pard\\sl360\\slmult1\n#{value}\n\\par}\n")
      end
    end

    context 'when style: indented_line' do
      context 'when no options given' do
        it 'returns the value inside correct styling tags' do
          expect(resource.perform(value:, style: :indented_line))
            .to eq("{\\li720 #{value} }\n")
        end
      end

      context 'when options given' do
        context 'when include_line_break: true' do
          let(:options) { { include_line_break: true } }

          it 'returns the value inside correct styling tags with the line break at the end' do
            expect(resource.perform(value:, style: :indented_line, options:))
              .to eq("{\\li720 #{value} \\line}\n")
          end
        end

        context 'when include_line_break: false' do
          let(:options) { { include_line_break: false } }

          it 'returns the value inside correct styling tags' do
            expect(resource.perform(value:, style: :indented_line))
              .to eq("{\\li720 #{value} }\n")
          end
        end
      end
    end

    context 'when style: color' do
      it 'returns the value with given color' do
        expect(resource.perform(value:, style: :color, options: { color: 'color_code' }))
          .to eq("\\color_code #{value}")
      end
    end

    context 'when style: document' do
      it 'returns the value inside correct styling tags' do
        expected_value = '{\\rtf1\\ansi\\deff0 {\\fonttbl {\\f0 Times New Roman;}}' \
                         "{\\colortbl;\\red93\\green45\\blue239;\\red252\\green97\\blue69;}\n#{value}\n}"
        expect(resource.perform(value:, style: :document)).to eq(expected_value)
      end
    end
  end
end
