# frozen_string_literal: true

FactoryBot.define do
  factory :apparatus_entry, class: 'Apparatus::Entry' do
    skip_create
    initialize_with do
      new(attributes)
    end

    token { build(:token) }
    index { Faker::Number.positive }
  end
end
