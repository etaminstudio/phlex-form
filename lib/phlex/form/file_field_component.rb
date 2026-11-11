# frozen_string_literal: true

module Phlex
  module Form
    class FileFieldComponent < FieldComponent
      self.tag_klass = ActionView::Helpers::Tags::FileField

      def before_render
        @options = { include_hidden: view_context.multiple_file_field_include_hidden }.merge!(options)
        @options = view_context.send(:convert_direct_upload_option_to_url, @options.dup) # private in Rails' FormHelper

        super
      end
    end
  end
end
