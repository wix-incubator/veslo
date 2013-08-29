require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'fakeweb'
require 'stringio'

def capture(*streams)
  streams.map! { |stream| stream.to_s }
  begin
    result = StringIO.new
    streams.each { |stream| eval "$#{stream} = result" }
    yield
  ensure
    streams.each { |stream| eval("$#{stream} = #{stream.upcase}") }
  end
  result.string
end

describe "Veslo", "parsing arguments" do
  before :each do
    @veslo = Veslo.new
  end

  it "should accept 3 well-formed arguments" do
    lambda{@veslo.parse_commands(["configurations", "get", "chix"])}.should_not raise_error(ArgumentError)
  end

  it "should accept 4 well-formed arguments" do
    lambda{@veslo.parse_commands(["configurations", "put", "chix", "chix.yml"])}.should_not raise_error(ArgumentError)
  end

  it "should not accept less than 3 arguments" do
    lambda{@veslo.parse_commands(["foo", "bar"])}.should raise_error(ArgumentError)
  end

  it "should not accept more than 4 arguments" do
    lambda{@veslo.parse_commands(["foo", "bar", "baz", "foobar", "foobaz"])}.should raise_error(ArgumentError)
  end

  it "should not accept unknown methods" do
    lambda{@veslo.parse_commands(["configurations", "head", "baz"])}.should raise_error(NotImplementedError)
  end

  it "should not accept unknown resources" do
    lambda{@veslo.parse_commands(["foobars", "get", "baz"])}.should raise_error(NotImplementedError)
  end
end
describe "Veslo", "interacting with server as a library" do
  before :all do
    FakeWeb.allow_net_connect = false
    FakeWeb.register_uri(:get, "http://example.com/configurations/existing", :body => "Hello World!")
    FakeWeb.register_uri(:put, "http://example.com/configurations/existing", :body => "Hello World!")
    FakeWeb.register_uri(:delete, "http://example.com/configurations/existing", :body => "Bye World!")
    FakeWeb.register_uri(:get, "http://example.com/configurations/missing", :body => "Nothing to be found 'round here", :status => ["404", "Not Found"])
    FakeWeb.register_uri(:put, "http://example.com/configurations/creating", :body => "Hello World!")
    @veslo = Veslo.client("http://example.com")
  end

  it "should get the a existing configuration" do
    @veslo.get("configurations", "existing").should == "Hello World!"
  end

  it "should delete the a existing configuration" do
    @veslo.delete("configurations", "existing", {:foo => "bar"}).should == "Bye World!"
  end

  it "should not get the a missing configuration" do
    lambda{ @veslo.get("configurations", "missing")}.should raise_error(RestClient::ResourceNotFound)
  end

  it "should upload a config" do
    @veslo.put("configurations", "existing", "{\"format\":\"app/octet\", \"body\":\"foo:\\n  bar: baz\\n  foobar: foobaz\\n\"}")
    FakeWeb.last_request.method.should == "PUT"
    FakeWeb.last_request.body.should == "{\"format\":\"app/octet\", \"body\":\"foo:\\n  bar: baz\\n  foobar: foobaz\\n\"}"
  end
end
describe "Veslo", "interacting with server from the comand line" do
  before :all do
    @veslo = Veslo.new
    @base_argv = ["-s", "http://example.com", "configurations"]
    @get_existing_argv = @base_argv + ["get", "existing"]
    @get_missing_argv = @base_argv + ["get", "missing"]
    @get_error_argv = @base_argv + ["get", "error"]
    @put_new_argv = @base_argv + ["put", "creating", "spec/fixtures/config.yaml"]
    @put_missing_argv = @base_argv + ["put", "config_name", "nofile.yml"]
    FakeWeb.allow_net_connect = false
    FakeWeb.register_uri(:get, "http://example.com/configurations/existing", :body => "Hello World!")
    FakeWeb.register_uri(:get, "http://example.com/configurations/missing", :body => "Nothing to be found 'round here", :status => ["404", "Not Found"])
    FakeWeb.register_uri(:get, "http://example.com/configurations/error", :body => "Internal Server Error", :status => ["500", "Internal Server Error"])

    FakeWeb.register_uri(:put, "http://example.com/configurations/creating", :body => "Hello World!")
  end

  it "should get an existing configuration" do
    @output = capture(:stdout) do
      @veslo.run!(*@get_existing_argv)
    end
    @output.should == "Hello World!\n"
  end

  it "should tell if a configuration was not found" do
    @output = capture(:stderr) do
      @veslo.run!(*@get_missing_argv)
    end
    @output.should == "Requested resource not found\n"
  end

  it "should tell what happened in case of failure" do
    @output = capture(:stderr) do
      @veslo.run!(*@get_error_argv)
    end
    @output.should == "Request failed with status: 500\n"
  end

  it "should not upload a missing file" do
    @output = capture(:stderr) do
      @veslo.run!(*@put_missing_argv)
    end
    @output.should == "File not found: nofile.yml\n"
  end

  it "should upload a config" do
    @output = capture(:stdout) do
      @veslo.run!(*@put_new_argv)
    end
    @output.should == "Config uploaded\n"
    FakeWeb.last_request.method.should == "PUT"
    FakeWeb.last_request.body.should == "{\"format\":\"app/octet\", \"body\":\"foo:\\n  bar: baz\\n  foobar: foobaz\\n\"}"
  end
end
