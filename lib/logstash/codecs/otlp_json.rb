# encoding: utf-8
require "logstash/codecs/base"

# This otlp_json codec will append a string to the message field
# of an event, either in the decoding or encoding methods
#
# This is only intended to be used as an example.
#
# input {
#   stdin { codec => otlp_json }
# }
#
# or
#
# output {
#   stdout { codec => otlp_json }
# }
#
class LogStash::Codecs::OtlpJson < LogStash::Codecs::Base

  # The codec name
  config_name "otlp_json"

  # Append a string to the message
  config :append, :validate => :string, :default => ', Hello World!'

  def register
    @lines = LogStash::Plugin.lookup("codec", "line").new
    @lines.charset = "UTF-8"
  end # def register

  def decode(data)
    @lines.decode(data) do |line|
      replace = { "message" => line.get("message").to_s + @append }
      yield LogStash::Event.new(replace)
    end
  end # def decode

  # Encode a single event, this returns the raw data to be returned as a String
  def encode_sync(event)
    event.get("message").to_s + @append + NL
  end # def encode_sync

end # class LogStash::Codecs::OtlpJson
