# frozen_string_literal: true

FactoryBot.define do
  factory :exporter_paragraph, class: 'Exporter::Models::Paragraph' do
    skip_create
    initialize_with do
      new(**attributes)
    end
    contents { build_list(:exporter_token, 2) }
  end
end
