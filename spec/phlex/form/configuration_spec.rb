# frozen_string_literal: true

RSpec.describe Phlex::Form::Configuration do
  subject(:configuration) { described_class.new }

  describe "defaults" do
    it do
      expect(configuration).to have_attributes(parent_component: "Phlex::HTML")
    end

    describe "#lookup_chain" do
      subject(:lookup_chain) { described_class.new.lookup_chain }

      it "by default implements one lookup lambda" do
        expect(lookup_chain.length).to be(1)
      end

      it "uses Component suffix" do
        expect(
          lookup_chain.first.call(:text_field, namespaces: [Phlex::Form])
        ).to be(Phlex::Form::TextFieldComponent)
      end

      it "finds the first klass that exists when given a list of namespaces" do
        expect(
          lookup_chain.first.call(
            :text_field,
            namespaces: [
              Form,
              Phlex::Form
            ]
          )
        ).to be(Form::TextFieldComponent)
      end
    end
  end
end
