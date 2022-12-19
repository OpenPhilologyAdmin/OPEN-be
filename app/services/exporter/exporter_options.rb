# frozen_string_literal: true

module Exporter
  class ExporterOptions
    include ActiveModel::Model
    include ActiveModel::Attributes
    LAYOUTS = %w[apparatus_at_the_end apparatus_in_the_text].freeze
    attribute :footnote_numbering, :boolean
    attribute :layout, :string

    validates :footnote_numbering, inclusion: [true, false]
    validates :layout, presence: true, inclusion: LAYOUTS

    alias footnote_numbering? footnote_numbering
  end
end
