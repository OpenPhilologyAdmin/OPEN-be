# frozen_string_literal: true

module Exporter
  class ApparatusOptions
    include ActiveModel::Model
    include ActiveModel::Attributes
    include Helpers::HasFullMessageErrorsHash

    attribute :footnote_numbering, :boolean
    attribute :significant_readings, :boolean
    attribute :insignificant_readings, :boolean
    attribute :selected_reading_separator, :string
    attribute :readings_separator, :string
    attribute :sigla_separator, :string

    validates :footnote_numbering, inclusion: [true, false]
    validates :significant_readings, :insignificant_readings, inclusion: [true, false]

    validates :selected_reading_separator, :readings_separator, :sigla_separator,
              presence: true

    alias footnote_numbering? footnote_numbering
    alias significant_readings? significant_readings
    alias insignificant_readings? insignificant_readings

    def include_apparatus?
      significant_readings? || insignificant_readings?
    end
  end
end
