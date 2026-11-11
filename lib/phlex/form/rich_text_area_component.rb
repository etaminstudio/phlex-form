# frozen_string_literal: true

module Phlex
  module Form
    class RichTextAreaComponent < FieldComponent
      if defined?(ActionView::Helpers::Tags::ActionText)
        def view_template
          options[:value] = content if content

          raw ActionView::Helpers::Tags::ActionText.new(object_name, method_name, view_context, options)
                                                   .render
        end
      end
    end
  end
end
