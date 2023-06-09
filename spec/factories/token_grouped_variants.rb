# frozen_string_literal: true

FactoryBot.define do
  factory :token_grouped_variant, class: 'TokenGroupedVariant' do
    transient do
      witnesses_number { 2 }
    end

    skip_create
    initialize_with do
      new(attributes)
    end
    witnesses { Array.new(witnesses_number) { Faker::Alphanumeric.alpha(number: 2).capitalize } }
    t { Faker::Lorem.sentence }
    selected { false }
    possible { false }

    trait :selected do
      selected { true }
      possible { true }
    end

    trait :secondary do
      selected { false }
      possible { true }
    end

    trait :insignificant do
      selected { false }
      possible { false }
    end
  end
end
