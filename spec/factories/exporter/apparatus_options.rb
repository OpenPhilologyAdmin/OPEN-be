# frozen_string_literal: true

FactoryBot.define do
  factory :apparatus_options, class: 'Exporter::ApparatusOptions' do
    skip_create
    initialize_with do
      new(attributes)
    end
    significant_readings { true }
    insignificant_readings { true }
    selected_reading_separator { ']' }
    readings_separator { ';' }
    sigla_separator { ':' }
    footnote_numbering { true }

    trait :invalid do
      significant_readings { nil }
      footnote_numbering { nil }
    end
  end
end
