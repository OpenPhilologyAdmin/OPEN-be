# frozen_string_literal: true

FactoryBot.define do
  factory :exporter_token, class: 'Exporter::Models::Token' do
    skip_create
    initialize_with do
      new(**attributes)
    end
    value { Faker::Lorem.sentence }
    apparatus_entry_index { Faker::Number.digit }
    footnote_numbering { true }

    trait :with_nil_value do
      value { FormattableT::NIL_VALUE_PLACEHOLDER }
    end
  end
end
