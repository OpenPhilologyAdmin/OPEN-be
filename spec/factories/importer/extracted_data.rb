# frozen_string_literal: true

FactoryBot.define do
  factory :extracted_data, class: 'Importer::ExtractedData' do
    transient do
      project { create(:project) }
    end
    skip_create
    initialize_with do
      new(attributes)
    end

    witnesses do
      build_list(:witness, 3)
    end

    tokens do
      build_list(:token, 3, witnesses:, project:)
    end
  end
end
