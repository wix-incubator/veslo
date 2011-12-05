require 'rubygems'
require 'mixlib/cli'
require 'rest_client'

class Veslo
  include Mixlib::CLI
  Veslo::SUPPORTED_METHODS = ["put", "get"]
  Veslo::SUPPORTED_RESOURCES = ["configurations"]

  option :server_url,
    :short => "-s SERVER",
    :long  => "--server SERVER",
    :description => "The Noah server to work against"

  def run!(*arguments)
    argv = parse_options(arguments)
    @server = RestClient::Resource.new(config[:server_url], :headers => {:accept => "application/octet"})
    parse_commands(argv)
    execute
  end

  def parse_commands(commands)
    raise ArgumentError.new("Not the right ammount of arguments") if commands.size != 3
    @resource = commands.shift
    @method = commands.shift
    @name = commands.shift
    validate_input
  end

  def validate_input
    raise NotImplementedError.new("method #{@method} not supported") unless SUPPORTED_METHODS.include?(@method)
    raise NotImplementedError.new("resource #{@resource} not supported") unless SUPPORTED_RESOURCES.include?(@resource)
  end

  def execute
    begin
      result = @server["#{@resource}/#{@name}"].get
      $stdout.puts result.to_str
      return 0
    rescue RestClient::ExceptionWithResponse => e
      case e.response.code
      when 404
        $stderr.puts("Requested resource not found")
        return 1
      else
        $stderr.puts("Request failed with status: #{e.response.code}")
        return 2
      end
    end
  end
end