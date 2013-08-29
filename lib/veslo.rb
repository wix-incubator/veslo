require 'rubygems'
require 'mixlib/cli'
require 'rest_client'
require 'json'

class Veslo
  include Mixlib::CLI
  SUPPORTED_METHODS = ["put", "get"]
  SUPPORTED_RESOURCES = ["configurations"]

  attr_accessor :server
  option :server_url,
    :short => "-s SERVER",
    :long  => "--server SERVER",
    :description => "The Noah server to work against"

  def run!(*arguments)
    argv = parse_options(arguments)
    @server = RestClient::Resource.new(config[:server_url], :headers => {:accept => "application/octet"})
    parse_commands(argv)
    send(:"resource_#{@method}_cli")
  end

  def self.client(server)
    client = self.new
    client.server = RestClient::Resource.new(server, :headers => {:accept => "application/octet"})
    client
  end

  def parse_commands(commands)
    raise ArgumentError.new("Not the right ammount of arguments") unless (3..4).include?(commands.size)
    @resource = commands.shift
    @method = commands.shift
    @name = commands.shift
    @file = commands.shift
    validate_input
  end

  def validate_input
    raise NotImplementedError.new("method #{@method} not supported") unless SUPPORTED_METHODS.include?(@method)
    raise NotImplementedError.new("resource #{@resource} not supported") unless SUPPORTED_RESOURCES.include?(@resource)
  end

  def get(resource, name)
    @resource = resource
    @name = name
    resource_get
  end

  def resource_get
    @server["#{@resource}/#{@name}"].get
  end

  def resource_get_cli
    result = resource_get
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

  def put(resource, name, data)
    @resource = resource
    @name = name
    resource_put(data)
  end

  def resource_put(data)
    @server["#{@resource}/#{@name}"].put(data)
  end

  def delete(resource, name)
    @resource = resource
    @name = name
    resource_delete
  end

  def resource_delete
    @server["#{@resource}/#{@name}"].delete
  end

  def resource_put_cli
    raise NotImplementedError, "No STDIN yet" unless @file
    file_content = File.open(@file, 'r').read
    put_data = "{\"format\":\"app/octet\", \"body\":#{file_content.to_json}}"
    result = resource_put(put_data)
    $stdout.puts "Config uploaded"
    return 0
  rescue Errno::ENOENT
    $stderr.puts "File not found: #{@file}"
    return 3
  end
end
