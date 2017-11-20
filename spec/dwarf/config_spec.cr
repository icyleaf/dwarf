require "../spec_helper"

config = Dwarf::Config.new

describe Dwarf::Config do
  it "should behave like a hash" do
    config["foo"] = "bar"
    config["foo"].should eq Dwarf::Config::Type.new "bar"
  end

  it "should provide hash property" do
    config.failure_app = "foo"
    config.failure_app.should eq Dwarf::Config::Type.new "foo"

    config.failure_app = "bar"
    config["failure_app"].should eq Dwarf::Config::Type.new "bar"
  end

  it "should allow to read and set default strategies" do
    config.default_strategies(["foo", "bar"])
    config.default_strategies.should eq [Dwarf::Config::Type.new("foo"), Dwarf::Config::Type.new("bar")]
  end

  it "should set the default_scope" do
    config.default_scope.should eq Dwarf::Config::Type.new "all"
    config.default_scope = "foo"
    config.default_scope.should eq Dwarf::Config::Type.new "foo"
  end

  it "should merge given options on initialization" do
    Dwarf::Config.new({ "foo" => Dwarf::Config::Type.new("bar") })["foo"].should eq Dwarf::Config::Type.new "bar"
  end
end
