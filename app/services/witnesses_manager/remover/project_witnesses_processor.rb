# frozen_string_literal: true

module WitnessesManager
  class Remover
    class ProjectWitnessesProcessor
      def initialize(project:, siglum:)
        @project = project
        @siglum = siglum
        @witnesses = @project.witnesses
      end

      def remove_witness!
        remove_from_witnesses
        handle_removed_default_witness
        @project.save
      end

      private

      def removing_default_witness?
        @project.default_witness == @siglum
      end

      def remove_from_witnesses
        @witnesses.delete_if { |witness| witness.siglum == @siglum }
      end

      def handle_removed_default_witness
        return unless removing_default_witness?

        @witnesses.first.default!
      end
    end
  end
end
