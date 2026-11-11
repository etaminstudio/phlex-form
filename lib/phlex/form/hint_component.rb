# frozen_string_literal: true

module Phlex
  module Form
    class HintComponent < FieldComponent
      class_attribute :tag, instance_reader: false, instance_writer: false, instance_accessor: false,
                            instance_predicate: false
      attr_reader :attribute_content

      self.tag = :div

      def initialize(form, object_name, method_name, content_or_options = nil, options = nil)
        options ||= {}

        content_is_options = content_or_options.is_a?(Hash)
        if content_is_options
          options.merge! content_or_options
          @attribute_content = nil
        else
          @attribute_content = content_or_options
        end

        super(form, object_name, method_name, options)
      end

      def view_template
        content_or_options = content.presence || attribute_content.presence

        raw view_context.tag.public_send(self.class.tag, content_or_options, **html_attributes)
      end

      def render?
        content.present? || attribute_content.present?
      end
    end
  end
end
