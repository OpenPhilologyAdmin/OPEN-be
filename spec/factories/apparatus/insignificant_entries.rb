# frozen_string_literal: true

FactoryBot.define do
  factory :apparatus_insignificant_entry, class: 'Apparatus::InsignificantEntry' do
    transient do
      with_empty_values { false }
    end

    skip_create
    initialize_with do
      new(attributes)
    end

    token { build(:token, with_empty_values:) }
    index { Faker::Number.positive }

    trait :variant_selected do
      token { build(:token, :variant_selected, with_empty_values:) }
    end
  end
end
