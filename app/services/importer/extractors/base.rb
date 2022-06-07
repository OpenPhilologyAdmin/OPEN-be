# frozen_string_literal: true

module Importer
  module Extractors
    class Base
      def initialize(data_path:, default_witness:)
        @data_path = data_path
        @file = File.open(data_path)
        @default_witness = default_witness
        @tokens = []
      end

      def process
        raise NotImplementedError
      end
    end
  end
end
