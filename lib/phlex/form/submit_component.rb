# frozen_string_literal: true

module Phlex
  module Form
    class SubmitComponent < BaseComponent
      attr_reader :value

      def initialize(form, value, options = {})
        @value = value

        super(form, nil, options)
      end

      def view_template
        raw view_context.submit_tag(value, options)
      end
    end
  end
end
