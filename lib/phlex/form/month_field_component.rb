# frozen_string_literal: true

module Phlex
  module Form
    class MonthFieldComponent < FieldComponent
      self.tag_klass = ActionView::Helpers::Tags::MonthField
    end
  end
end
