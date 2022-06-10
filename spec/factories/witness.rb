# frozen_string_literal: true

FactoryBot.define do
  factory :witness, class: 'Witness' do
    skip_create
    initialize_with do
      new(attributes)
    end
    siglum { Faker::Alphanumeric.alpha(number: 2) }
    name { Faker::Lorem.sentence }
  end
end
