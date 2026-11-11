# frozen_string_literal: true

module Phlex
  module Form
    class EmailFieldComponent < FieldComponent
      self.tag_klass = ActionView::Helpers::Tags::EmailField
    end
  end
end
