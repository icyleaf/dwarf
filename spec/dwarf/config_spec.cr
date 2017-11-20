require "../spec_helper"

Spec2.describe Dwarf::Config do
  let(config) { Dwarf::Config.new }

  it "should behave like a hash" do
    config["foo"] = "bar"
    expect(config["foo"]).to eq Dwarf::Config::Type.new "bar"
  end

  it "should provide hash property" do
    config.failure_app = "foo"
    expect(config.failure_app).to eq Dwarf::Config::Type.new "foo"

    config.failure_app = "bar"
    expect(config["failure_app"]).to eq Dwarf::Config::Type.new "bar"
  end

  it "should allow to read and set default strategies" do
    config.default_strategies(["foo", "bar"])
    expect(config.default_strategies).to eq [Dwarf::Config::Type.new("foo"), Dwarf::Config::Type.new("bar")]
  end

  it "should set the default_scope" do
    expect(config.default_scope).to eq Dwarf::Config::Type.new "all"
    config.default_scope = "foo"
    expect(config.default_scope).to eq Dwarf::Config::Type.new "foo"
  end

  it "should merge given options on initialization" do
    expect(Dwarf::Config.new({ "foo" => Dwarf::Config::Type.new("bar") })["foo"]).to eq Dwarf::Config::Type.new "bar"
  end
end
