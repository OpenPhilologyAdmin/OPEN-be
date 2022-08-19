# frozen_string_literal: true

module TokensManager
  class Updater < Base
    AUTO_SELECTED_EDITORIAL_REMARKS = ['em.', 'conj.'].freeze

    delegate :will_save_change_to_variants?, :will_save_change_to_editorial_remark?, to: :token

    def perform
      success = update_token
      update_last_editor if success

      Result.new(success:, token:)
    end

    private

    def editorial_remark_witness
      @editorial_remark_witness ||= token.editorial_remark_witness
    end

    def variants_and_remarks
      @variants_and_remarks ||= [token.variants, token.editorial_remark].flatten.compact
    end

    def update_token
      token.assign_attributes(params)
      generate_grouped_variants
      auto_select_editorial_remark
      token.save
    end

    def generate_grouped_variants?
      return false unless token.valid?

      will_save_change_to_variants? || will_save_change_to_editorial_remark?
    end

    def generate_grouped_variants
      return unless generate_grouped_variants?

      token.grouped_variants = GroupedVariantsGenerator.perform(variants_and_remarks)
    end

    def auto_select_editorial_remark?
      will_save_change_to_editorial_remark? && AUTO_SELECTED_EDITORIAL_REMARKS.include?(editorial_remark_witness)
    end

    def auto_select_editorial_remark
      return unless auto_select_editorial_remark?

      token.grouped_variants.each do |grouped_variant|
        update_selections(grouped_variant)
      end
    end

    def update_selections(grouped_variant)
      value = grouped_variant.for_witness?(editorial_remark_witness)
      grouped_variant.selected = value
      grouped_variant.possible = value
    end

    def update_last_editor
      token.project.update(last_editor: user)
    end
  end
end
