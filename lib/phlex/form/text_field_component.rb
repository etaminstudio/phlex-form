# frozen_string_literal: true

module Phlex
  module Form
    class TextFieldComponent < FieldComponent
      self.tag_klass = ActionView::Helpers::Tags::TextField
    end
  end
end
