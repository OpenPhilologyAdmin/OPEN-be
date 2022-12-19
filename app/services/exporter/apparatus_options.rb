# frozen_string_literal: true

module Exporter
  class ApparatusOptions
    include ActiveModel::Model
    include ActiveModel::Attributes
    include Helpers::HasFullMessageErrorsHash

    attribute :significant_readings, :boolean
    attribute :insignificant_readings, :boolean
    attribute :selected_reading_separator, :string
    attribute :secondary_readings_separator, :string
    attribute :insignificant_readings_separator, :string
    attribute :entries_separator, :string

    validates :significant_readings, :insignificant_readings, inclusion: [true, false]

    validates :selected_reading_separator, :secondary_readings_separator,
              :insignificant_readings_separator, :entries_separator,
              presence: true

    alias significant_readings? significant_readings
    alias insignificant_readings? insignificant_readings

    def include_apparatus?
      significant_readings? || insignificant_readings?
    end
  end
end
