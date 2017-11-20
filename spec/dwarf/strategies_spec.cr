require "../spec_helper"

private class FooStrategy < Dwarf::Strategies::Base
  def valid?
    true
  end

  def authenticate!
  end
end

Spec2.describe Dwarf::Strategies do
  it "should allow me to add a strategy with the required methods" do
    expect(Dwarf::Strategies.register("foo", FooStrategy.new)).to be_a FooStrategy
  end

  it "should allow me to clear the strategies" do
    Dwarf::Strategies.register("foo", FooStrategy.new)

    expect(Dwarf::Strategies["foo"]?).not_to be_nil
    Dwarf::Strategies.clear!
    expect(Dwarf::Strategies["foo"]?).to be_nil
  end

  it "should raise an exception if not found strategy" do
    expect do
      Dwarf::Strategies["bar"]
    end.to raise_error KeyError
  end
end
