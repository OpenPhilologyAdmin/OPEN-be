# frozen_string_literal: true

FactoryBot.define do
  factory :exporter_options, class: 'Exporter::ExporterOptions' do
    skip_create
    initialize_with do
      new(attributes)
    end
    footnote_numbering { true }
    layout { Exporter::ExporterOptions::LAYOUTS.sample }
  end
end
