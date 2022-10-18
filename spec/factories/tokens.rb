# frozen_string_literal: true

FactoryBot.define do
  factory :token do
    transient do
      with_empty_values { false }
      witnesses { project.witnesses }
    end

    project { create(:project) }
    index { Faker::Number.positive }
    variants do
      witnesses.map do |witness|
        build(:token_variant, witness: witness.siglum)
      end
    end

    grouped_variants do
      TokensManager::GroupedVariantsGenerator.perform(token: self)
    end

    editorial_remark { build(:token_editorial_remark) }

    trait :without_project do
      project { nil }
    end

    trait :variant_selected do
      project { create(:project, witnesses_number: 3) }
      variants do
        witnesses.map do |witness|
          build(:token_variant,
                witness: witness.siglum)
        end
      end

      # first variant is the selected one
      grouped_variants do
        records = TokensManager::GroupedVariantsGenerator.perform(token: self)

        records.each_with_index do |variant, index|
          variant.selected = index.zero?
          variant.possible = index.zero?
        end

        records
      end
    end

    trait :variant_selected_and_secondary do
      project { create(:project, witnesses_number: 3) }
      variants do
        witnesses.map do |witness|
          build(:token_variant,
                witness: witness.siglum)
        end
      end

      # first variant is the selected one, others are possible
      grouped_variants do
        records = TokensManager::GroupedVariantsGenerator.perform(token: self)

        records.each_with_index do |variant, index|
          variant.selected = index.zero?
          variant.possible = true
        end

        records
      end
    end

    trait :without_editorial_remark do
      editorial_remark { nil }
    end

    trait :one_grouped_variant do
      value = Faker::Lorem.sentence

      variants do
        witnesses.map do |witness|
          build(:token_variant, witness: witness.siglum, t: value)
        end
      end

      editorial_remark { nil }
    end

    trait :resized do
      resized { true }
    end

    after(:build) do |token, evaluator|
      if evaluator.with_empty_values
        token.variants.each { |variant| variant.t = nil }
        token.grouped_variants.each { |variant| variant.t = nil }
      end
    end
  end
end
