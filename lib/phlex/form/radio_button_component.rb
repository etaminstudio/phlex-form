# frozen_string_literal: true

module Phlex
  module Form
    class RadioButtonComponent < FieldComponent
      self.tag_klass = ActionView::Helpers::Tags::RadioButton

      attr_reader :value

      def initialize(form, object_name, method_name, value, options = {})
        @value = value

        super(form, object_name, method_name, options)
      end

      def view_template
        raw ActionView::Helpers::Tags::RadioButton.new(
          object_name,
          method_name,
          view_context,
          value,
          options
        ).render
      end
    end
  end
end
