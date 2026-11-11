# frozen_string_literal: true

module Phlex
  module Form
    class SearchFieldComponent < FieldComponent
      self.tag_klass = ActionView::Helpers::Tags::SearchField
    end
  end
end
