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
    secondary_readings_separator { ',' }
    insignificant_readings_separator { ',' }
    entries_separator { ';' }
  end
end
