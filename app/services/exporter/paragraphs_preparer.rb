# frozen_string_literal: true

module Exporter
  class ParagraphsPreparer
    def initialize(project:, exporter_options:, apparatus_options:)
      @project           = project
      @exporter_options  = exporter_options
      @apparatus_options = apparatus_options
    end

    def self.perform(project:, exporter_options:, apparatus_options:)
      new(project:, exporter_options:, apparatus_options:).perform
    end

    def perform
      add_data_to_paragraphs
      [
        tokens_paragraph,
        apparatuses_paragraph
      ]
    end

    private

    attr_reader :project, :exporter_options, :apparatus_options

    delegate :tokens, to: :project, prefix: true
    delegate :footnote_numbering?, to: :exporter_options

    def tokens_paragraph
      @tokens_paragraph ||= Models::Paragraph.new
    end

    def apparatuses_paragraph
      @apparatuses_paragraph ||= Models::Paragraph.new
    end

    def add_data_to_paragraphs
      apparatus_index = 0
      project_tokens.each do |token|
        apparatus_index += 1 if token.apparatus?
        process_token(token_with_index: TokenWithIndex.new(token, apparatus_index))
      end
    end

    def process_token(token_with_index:)
      add_token_to_paragraph(token_with_index:)
      add_apparatus_to_paragraph(token_with_index:)
    end

    def add_token_to_paragraph(token_with_index:)
      tokens_paragraph.contents << Models::Token.new(
        value:              token_with_index.t,
        footnote_numbering: footnote_numbering?,
        index:              token_with_index.index
      )
    end

    def add_apparatus_to_paragraph(token_with_index:)
      return unless token_with_index.apparatus?

      apparatuses_paragraph.contents << Models::Apparatus.new(
        selected_variant:       token_with_index.selected_variant,
        secondary_variants:     token_with_index.secondary_variants,
        insignificant_variants: token_with_index.insignificant_variants,
        apparatus_options:,
        index:                  token_with_index.index
      )
    end

    class TokenWithIndex
      def initialize(token, apparatus_index)
        @token = token
        @apparatus_index = apparatus_index
      end

      delegate :apparatus?, :t, to: :token
      delegate :selected_variant, :secondary_variants, :insignificant_variants, to: :token

      def index
        apparatus_index if apparatus?
      end

      private

      attr_reader :token, :apparatus_index
    end
  end
end
