# frozen_string_literal: true

FactoryBot.define do
  factory :apparatus_insignificant_entry, class: 'Apparatus::InsignificantEntry' do
    skip_create
    initialize_with do
      new(attributes)
    end

    token { build(:token) }
    index { Faker::Number.positive }

    trait :variant_selected do
      token { build(:token, :variant_selected) }
    end
  end
end
