# frozen_string_literal: true

module Phlex
  module Form
    class ErrorMessageComponent < FieldComponent
      class_attribute :tag, instance_reader: false, instance_writer: false, instance_accessor: false,
                            instance_predicate: false

      self.tag = :div

      def view_template
        raw view_context.tag.public_send(self.class.tag, messages, **html_attributes)
      end

      def render?
        method_errors?
      end

      def messages
        view_context.safe_join(method_errors, view_context.tag.br)
      end
    end
  end
end
