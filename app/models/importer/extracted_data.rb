# frozen_string_literal: true

module Importer
  class ExtractedData
    include ActiveModel::Model

    attr_accessor :tokens, :witnesses
  end
end
