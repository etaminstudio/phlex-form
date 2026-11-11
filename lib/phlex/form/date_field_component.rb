# frozen_string_literal: true

module Phlex
  module Form
    class DateFieldComponent < FieldComponent
      self.tag_klass = ActionView::Helpers::Tags::DateField
    end
  end
end
