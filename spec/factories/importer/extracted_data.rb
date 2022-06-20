# frozen_string_literal: true

FactoryBot.define do
  factory :extracted_data, class: 'Importer::ExtractedData' do
    skip_create
    initialize_with do
      new(attributes)
    end

    tokens do
      build_list(:token, 3)
    end

    witnesses do
      build_list(:witness, 3)
    end
  end
end
