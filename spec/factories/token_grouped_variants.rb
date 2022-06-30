# frozen_string_literal: true

FactoryBot.define do
  factory :token_grouped_variant, class: 'TokenGroupedVariant' do
    skip_create
    initialize_with do
      new(attributes)
    end
    witnesses { [Faker::Alphanumeric.alpha(number: 2), Faker::Alphanumeric.alpha(number: 2)] }
    t { Faker::Lorem.sentence }
    selected { false }
    possible { false }
  end
end
