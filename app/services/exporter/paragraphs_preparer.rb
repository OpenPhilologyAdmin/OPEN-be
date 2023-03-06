# frozen_string_literal: true

module Exporter
  class ParagraphsPreparer
    def initialize(project:, apparatus_options:)
      @project           = project
      @apparatus_options = apparatus_options
      @paragraphs = []
    end

    def self.perform(project:, apparatus_options:)
      new(project:, apparatus_options:).perform
    end

    def perform
      add_data_to_paragraphs
      paragraphs
    end

    private

    attr_reader :project, :apparatus_options
    attr_accessor :paragraphs

    delegate :tokens, to: :project, prefix: true
    delegate :footnote_numbering?, to: :apparatus_options
    delegate :include_apparatus?, to: :apparatus_options, prefix: true

    def add_data_to_paragraphs(apparatus_entry_index: 0)
      current_paragraph = Models::Paragraph.new

      project_tokens.each do |token|
        if token.apparatus?
          apparatus_entry_index += 1
          current_paragraph = process_token_with_apparatus(current_paragraph:, token:, apparatus_entry_index:)
        else
          current_paragraph.push(token_for_paragraph(token:))
        end
      end
      paragraphs.push(current_paragraph) unless current_paragraph.empty?
    end

    def process_token_with_apparatus(current_paragraph:, token:, apparatus_entry_index:)
      current_paragraph.push(token_for_paragraph(token:, apparatus_entry_index:))
      return current_paragraph unless apparatus_options_include_apparatus?

      paragraphs.push(current_paragraph)
      paragraphs.push(paragraph_with_apparatus(token:))

      Models::Paragraph.new
    end

    def token_for_paragraph(token:, apparatus_entry_index: nil)
      Models::Token.new(
        value:                 token.t,
        footnote_numbering:    footnote_numbering?,
        apparatus_entry_index:
      )
    end

    def paragraph_with_apparatus(token:)
      Models::Paragraph.new(
        contents: [
          apparatus_for_paragraph(token:)
        ]
      )
    end

    def apparatus_for_paragraph(token:)
      Models::Apparatus.new(
        selected_variant:       token.selected_variant,
        secondary_variants:     token.secondary_variants,
        insignificant_variants: token.insignificant_variants,
        apparatus_options:
      )
    end
  end
end
