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
      paragraphs
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
      apparatus_entry_index = 0
      project_tokens.each do |token|
        if token.apparatus?
          apparatus_entry_index += 1
          add_token_to_paragraph(token:, apparatus_entry_index:)
          add_apparatus_to_paragraph(token:, apparatus_entry_index:)
        else
          add_token_to_paragraph(token:)
        end
      end
    end

    def add_token_to_paragraph(token:, apparatus_entry_index: nil)
      tokens_paragraph.contents << Models::Token.new(
        value:                 token.t,
        footnote_numbering:    footnote_numbering?,
        apparatus_entry_index:
      )
    end

    def add_apparatus_to_paragraph(token:, apparatus_entry_index:)
      apparatuses_paragraph.contents << Models::Apparatus.new(
        selected_variant:       token.selected_variant,
        secondary_variants:     token.secondary_variants,
        insignificant_variants: token.insignificant_variants,
        apparatus_options:,
        index:                  apparatus_entry_index
      )
    end

    def paragraphs
      result = [tokens_paragraph]
      result << apparatuses_paragraph if apparatuses_paragraph.contents.any?
      result
    end
  end
end
