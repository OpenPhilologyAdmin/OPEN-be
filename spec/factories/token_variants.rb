# frozen_string_literal: true

FactoryBot.define do
  factory :token_variant, class: 'TokenVariant' do
    skip_create
    initialize_with do
      new(attributes)
    end
    witness { Faker::Alphanumeric.alpha(number: 2) }
    t { Faker::Lorem.sentence }
  end
end
