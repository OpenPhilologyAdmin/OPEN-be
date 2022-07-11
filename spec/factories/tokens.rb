# frozen_string_literal: true

FactoryBot.define do
  factory :token do
    project { create(:project) }
    index { Faker::Number.positive }
    variants do
      project.witnesses.map do |witness|
        build(:token_variant, witness: witness.siglum)
      end
    end

    grouped_variants do
      project.witnesses.map do |witness|
        build(:token_grouped_variant, witnesses: [witness.siglum])
      end
    end

    trait :without_project do
      project { nil }
    end
  end
end
