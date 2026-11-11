# frozen_string_literal: true

module Phlex
  module Form
    class DatetimeLocalFieldComponent < FieldComponent
      self.tag_klass = ActionView::Helpers::Tags::DatetimeLocalField
    end
  end
end
