# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Token do
  describe '#validations' do
    subject(:token) { described_class.new }

    it { is_expected.to validate_presence_of(:index) }
    it { is_expected.to validate_presence_of(:variants) }
    it { is_expected.to validate_presence_of(:grouped_variants) }

    context 'when grouped variants validation' do
      context 'when more than one variant was selected as a primary reading' do
        let(:token) { build(:token, grouped_variants: build_list(:token_grouped_variant, 2, :selected)) }
        let(:expected_error) do
          I18n.t('activerecord.errors.models.token.attributes.grouped_variants.more_than_one_selected')
        end

        it 'is not valid' do
          expect(token).not_to be_valid
        end

        it 'assigns correct error to :grouped_variants' do
          token.valid?
          expect(token.errors[:grouped_variants]).to include(expected_error)
        end
      end

      context 'when just one variant selected' do
        let(:token) { build(:token, grouped_variants: [build(:token_grouped_variant, :selected)]) }

        it 'is valid' do
          expect(token).to be_valid
        end
      end

      context 'when there are no selected variants' do
        let(:token) { build(:token, grouped_variants: [build(:token_grouped_variant, :secondary)]) }

        it 'is valid' do
          expect(token).to be_valid
        end
      end
    end
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

    it 'creates valid one_variant factory' do
      expect(build(:token, :one_grouped_variant)).to be_valid
    end

    it 'creates valid without_editorial_remark factory' do
      expect(build(:token, :without_editorial_remark)).to be_valid
    end

    it 'creates valid :resized factory' do
      expect(build(:token, :resized)).to be_valid
    end
  end

  context 'when variants & evaluated' do
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

      describe '#significant_variants?' do
        it 'is false' do
          expect(token).not_to be_significant_variants
        end
      end

      describe '#insignificant_variants' do
        it 'returns all variants' do
          expect(token.insignificant_variants).to match_array(token.grouped_variants)
        end
      end

      describe '#t' do
        it 'equals the :formatted_t of the default_variant' do
          expect(token.t).to eq(token.default_variant.formatted_t)
        end
      end

      describe '#evaluated?' do
        it 'is false' do
          expect(token).not_to be_evaluated
        end
      end
    end

    context 'when there is a selected variant' do
      let(:selected_variant) { token.grouped_variants.find { |variant| !variant.for_witness?(default_witness) } }

      before do
        selected_variant.selected = true
        selected_variant.t        = nil
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

      describe '#significant_variants?' do
        context 'when there is only the selected variant and insignificant ones' do
          it 'is false' do
            expect(token).not_to be_significant_variants
          end
        end

        context 'when there are secondary variants as well' do
          let(:token) { create(:token, :variant_selected_and_secondary) }

          it 'is true' do
            expect(token).to be_significant_variants
          end
        end
      end

      describe '#insignificant_variants' do
        it 'returns all variants that are not selected' do
          expect(token.insignificant_variants).to all(be_insignificant)
        end
      end

      describe '#t' do
        it 'equals the :formatted_t of the selected_variant' do
          expect(token.t).to eq(selected_variant.formatted_t)
        end
      end

      describe '#evaluated?' do
        it 'is true' do
          expect(token).to be_evaluated
        end
      end
    end
  end

  describe '#one_grouped_variant?' do
    context 'when there is just one grouped variant' do
      let(:token) { create(:token, grouped_variants: build_list(:token_grouped_variant, 1)) }

      it 'is truthy' do
        expect(token).to be_one_grouped_variant
      end
    end

    context 'when there are more grouped variant' do
      let(:token) { create(:token, grouped_variants: build_list(:token_grouped_variant, 2)) }

      it 'is falsey' do
        expect(token).not_to be_one_grouped_variant
      end
    end
  end

  describe '#state' do
    context 'when has the same reading for all witnesses (one grouped_variant)' do
      let(:token) { create(:token, :one_grouped_variant) }

      before do
        allow(token).to receive(:evaluatable?).and_return(evaluatable)
      end

      context 'when is not evaluatable' do
        let(:evaluatable) { false }

        it 'returns :one_variant' do
          expect(token.state).to eq(:one_variant)
        end
      end

      context 'when is evaluatable' do
        let(:evaluatable) { true }

        it 'returns :not_evaluated' do
          expect(token.state).to eq(:not_evaluated)
        end
      end
    end

    context 'when there are more readings (multiple grouped_variants)' do
      let(:token) { create(:token, grouped_variants:) }

      context 'when there is no :selected variant yet' do
        let(:grouped_variants) { build_list(:token_grouped_variant, 2, :insignificant) }

        it 'returns :not_evaluated' do
          expect(token.state).to eq(:not_evaluated)
        end
      end

      context 'when there is only the :selected variant' do
        let(:grouped_variants) do
          [
            build(:token_grouped_variant, :selected),
            build(:token_grouped_variant, :insignificant)
          ]
        end

        it 'returns :evaluated_with_single' do
          expect(token.state).to eq(:evaluated_with_single)
        end
      end

      context 'when there is the :selected variant and :secondary variant' do
        let(:grouped_variants) do
          [
            build(:token_grouped_variant, :selected),
            build(:token_grouped_variant, :secondary)
          ]
        end

        it 'returns :evaluated_with_multiple' do
          expect(token.state).to eq(:evaluated_with_multiple)
        end
      end
    end
  end

  describe '#evaluatable?' do
    context 'when the readings are the same for all variants' do
      context 'when resized: true' do
        it 'is truthy' do
          expect(build(:token, :resized, :one_grouped_variant)).to be_evaluatable
        end
      end

      context 'when resized: false' do
        it 'is falsey' do
          expect(build(:token, :one_grouped_variant)).not_to be_evaluatable
        end
      end
    end

    context 'when there are multiple readings' do
      context 'when there are no selected/possible variants yet' do
        it 'is truthy' do
          expect(build(:token)).to be_evaluatable
        end
      end

      context 'when there are already some selected/possible variants' do
        it 'is truthy' do
          expect(build(:token, :variant_selected_and_secondary)).to be_evaluatable
        end
      end
    end
  end

  describe '#apparatus' do
    let(:token) { build(:token) }
    let(:expected_value) { Apparatus::SignificantEntry.new(token:).value }

    it 'equals the value of Apparatus::SignificantEntry' do
      expect(token.apparatus).to eq(expected_value)
    end
  end
end
