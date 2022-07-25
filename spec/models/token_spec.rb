# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Token, type: :model do
  describe '#validations' do
    subject(:token) { described_class.new }

    it { is_expected.to validate_presence_of(:index) }
    it { is_expected.to validate_presence_of(:variants) }
  end

  describe 'factories' do
    it 'creates valid default factory' do
      expect(build(:token)).to be_valid
    end

    it 'creates valid variant_selected factory' do
      expect(build(:token, :variant_selected)).to be_valid
    end

    it 'creates valid variant_selected_and_secondary factory' do
      expect(build(:token, :variant_selected_and_secondary)).to be_valid
    end
  end

  context 'when variants & apparatus' do
    let(:default_witness) { 'A' }
    let(:project) { create(:project, default_witness:) }
    let(:token) { create(:token, project:) }

    context 'when there are no variants selected' do
      describe '#default_variant' do
        it 'equals the variant for the project\'s default witness' do
          expect(token.default_variant).to be_for_witness(default_witness)
        end
      end

      describe '#selected_variant' do
        it 'is nil' do
          expect(token.selected_variant).to be_nil
        end
      end

      describe '#current_variant' do
        it 'equals the default_variant' do
          expect(token.current_variant).to eq(token.default_variant)
        end
      end

      describe '#secondary_variants' do
        it 'is empty' do
          expect(token.secondary_variants).to be_empty
        end
      end

      describe '#t' do
        it 'equals the :t of the default_variant' do
          expect(token.t).to eq(token.default_variant.t)
        end
      end

      describe '#apparatus?' do
        it 'is false' do
          expect(token).not_to be_apparatus
        end
      end
    end

    context 'when there is a selected variant' do
      let(:selected_variant) { token.grouped_variants.find { |variant| !variant.for_witness?(default_witness) } }

      before do
        selected_variant.selected = true
      end

      describe '#default_variant' do
        it 'equals the variant for the project\'s default witness' do
          expect(token.default_variant).to be_for_witness(default_witness)
        end
      end

      describe '#selected_variant' do
        it 'equals the variant that was selected' do
          expect(token.selected_variant).to eq(selected_variant)
        end
      end

      describe '#current_variant' do
        it 'equals the selected_variant' do
          expect(token.current_variant).to eq(selected_variant)
        end
      end

      describe '#secondary_variants' do
        context 'when there is only the selected variant and insignificant ones' do
          it 'is empty' do
            expect(token.secondary_variants).to be_empty
          end
        end

        context 'when there are secondary variants as well' do
          let(:token) { create(:token, :variant_selected_and_secondary) }

          it 'returns marching secondary variants' do
            expect(token.secondary_variants).to all(be_secondary)
          end
        end
      end

      describe '#t' do
        it 'equals the :t of the selected_variant' do
          expect(token.t).to eq(selected_variant.t)
        end
      end

      describe '#apparatus?' do
        it 'is true' do
          expect(token).to be_apparatus
        end
      end
    end
  end
end
