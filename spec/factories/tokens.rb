# frozen_string_literal: true

FactoryBot.define do
  factory :token do
    project { create(:project) }
    index { Faker::Number.positive }
    variants do
      [
        [{ witness: 'D', t: 'Ipsum', selected: true, deleted: false }],
        [{ witness: 'A', t: 'Ipsum', selected: true, deleted: false }],
        [{ witness: 'B', t: 'Ipsume', selected: false, deleted: false }]
      ]
    end
    grouped_variants do
      [
        { t: 'Ipsum', witnesses: %w[D A], selected: true },
        { t: 'Ipsume', witnesses: ['B'] }
      ]
    end
  end
end
