# frozen_string_literal: true

module Phlex
  module Form
    class NumberFieldComponent < FieldComponent
      self.tag_klass = ActionView::Helpers::Tags::NumberField
    end
  end
end
