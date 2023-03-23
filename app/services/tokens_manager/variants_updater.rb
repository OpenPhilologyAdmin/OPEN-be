# frozen_string_literal: true

module TokensManager
  class VariantsUpdater < Updater
    AUTO_SELECTED_EDITORIAL_REMARKS = %w[em. conj.].freeze

    delegate :will_save_change_to_variants?, :will_save_change_to_editorial_remark?, to: :token

    def initialize(token:, user:, params: {})
      params = ProcessedParams.new(params:).params
      super
    end

    private

    def editorial_remark_witness
      @editorial_remark_witness ||= token.editorial_remark_witness
    end

    def update_token
      token.assign_attributes(params)
      generate_grouped_variants
      auto_select_editorial_remark
      token.save
    end

    def generate_grouped_variants
      token.grouped_variants = GroupedVariantsGenerator.perform(token:)
    end

    def auto_select_editorial_remark
      return unless auto_select_editorial_remark?

      token.grouped_variants.each do |grouped_variant|
        update_selections(grouped_variant)
      end
    end

    def auto_select_editorial_remark?
      will_save_change_to_editorial_remark? && AUTO_SELECTED_EDITORIAL_REMARKS.include?(editorial_remark_witness)
    end

    def update_selections(grouped_variant)
      value                    = grouped_variant.for_witness?(editorial_remark_witness)
      grouped_variant.selected = value
      grouped_variant.possible = value
    end

    class ProcessedParams
      def initialize(params:)
        @params           = params
        @variants         = params[:variants]
        @editorial_remark = params[:editorial_remark]

        handle_empty_values
      end

      attr_accessor :params

      private

      attr_accessor :variants, :editorial_remark

      # only nil and '' should be processed
      # multiple whitespaces are valid value
      def handle_empty_values
        cast_empty_variants
        remove_empty_editorial_remark
      end

      def cast_empty_variants
        return if variants.blank?

        variants.map do |variant|
          cast_empty_t_to_nil(variant)
        end
      end

      def cast_empty_t_to_nil(variant)
        return if variant[:t].nil?
        return unless variant[:t].empty?

        variant[:t] = nil
      end

      def remove_empty_editorial_remark
        return if editorial_remark.blank?
        return unless editorial_remark_t_empty?

        params[:editorial_remark] = nil
      end

      def editorial_remark_t_empty?
        return true if editorial_remark[:t].nil?
        return true if editorial_remark[:t].empty?

        false
      end
    end
  end
end
