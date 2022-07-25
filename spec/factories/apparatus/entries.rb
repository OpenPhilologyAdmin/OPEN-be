# frozen_string_literal: true

FactoryBot.define do
  factory :apparatus_entry, class: 'Apparatus::Entry' do
    skip_create
    initialize_with do
      new(attributes)
    end

    token { build(:token) }
    index { Faker::Number.positive }

    trait :variant_selected do
      token { build(:token, :variant_selected) }
    end

    trait :variant_selected_and_secondary do
      token { build(:token, :variant_selected_and_secondary) }
    end
  end
end
