require "../spec_helper"

private class FooStrategy < Dwarf::Strategies::Base
  def valid?
    true
  end

  def authenticate!
  end
end

describe Dwarf::Strategies do
  it "should allow me to add a strategy with the required methods" do
    Dwarf::Strategies.register("foo", FooStrategy.new).class.should eq FooStrategy
  end

  it "should allow me to clear the strategies" do
    Dwarf::Strategies.register("foo", FooStrategy.new)

    Dwarf::Strategies["foo"]?.should_not be_nil
    Dwarf::Strategies.clear!
    Dwarf::Strategies["foo"]?.should be_nil
  end

  it "should raise an exception if not found strategy" do
    expect_raises KeyError do
      Dwarf::Strategies["bar"]
    end
  end
end
