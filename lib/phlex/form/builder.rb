# frozen_string_literal: true

module Phlex
  module Form
    class Builder < ActionView::Helpers::FormBuilder
      include Phlex::Form::Renderer
      include Phlex::Form::ValidationContext
      include Phlex::Form::Helpers::Rails
      include Phlex::Form::Helpers::Rails8
      include Phlex::Form::Helpers::Custom
    end
  end
end
