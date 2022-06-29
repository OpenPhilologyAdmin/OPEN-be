# frozen_string_literal: true

FactoryBot.define do
  factory :token do
    project { create(:project) }
    index { Faker::Number.positive }
    variants { build_list(:token_variant, 3) }
    grouped_variants { build_list(:token_grouped_variant, 2) }

    trait :without_project do
      project { nil }
    end
  end
end
