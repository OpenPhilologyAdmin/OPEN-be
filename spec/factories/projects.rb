# frozen_string_literal: true

FactoryBot.define do
  factory :project do
    name { Faker::Lorem.word }
    default_witness { 'D' }
    witnesses do
      [
        {
          witness: 'D',
          name:    'D witness'
        },
        {
          witness: 'E',
          name:    'E witness'
        }
      ]
    end
  end
end
