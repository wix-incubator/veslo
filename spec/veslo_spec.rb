require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Veslo" do
  before :each do
    @veslo = Veslo.new
  end

  it "should accept 3 well-formed arguments" do
    lambda{@veslo.parse_commands(["configurations", "get", "chix"])}.should_not raise_error(ArgumentError)
  end

  it "should not accept less than 3 arguments" do
    lambda{@veslo.parse_commands(["foo", "bar"])}.should raise_error(ArgumentError)
  end

  it "should not accept more than 3 arguments" do
    lambda{@veslo.parse_commands(["foo", "bar", "baz", "foobar"])}.should raise_error(ArgumentError)
  end

  it "should not accept unknown methods" do
    lambda{@veslo.parse_commands(["configurations", "head", "baz"])}.should raise_error(NotImplementedError)
  end

  it "should not accept unknown resources" do
    lambda{@veslo.parse_commands(["foobars", "get", "baz"])}.should raise_error(NotImplementedError)
  end
end
