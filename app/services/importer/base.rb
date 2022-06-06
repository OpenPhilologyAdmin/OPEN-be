# frozen_string_literal: true

module Importer
  class Base
    ALLOWED_MIME_TYPES = ['text/plain'].freeze

    attr_reader :errors

    def initialize(data_path: nil)
      @data_path = Rails.root.join(data_path)
      @errors    = {}
    end
  end
end
