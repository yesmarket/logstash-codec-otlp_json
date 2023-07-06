# encoding: utf-8
require "logstash/codecs/base"
require "logstash/util/charset"
require "logstash/json"
require "logstash/event"
require "json"

class LogStash::Codecs::OtlpJson < LogStash::Codecs::Base

   config_name "otlp_json"

   def register
      @json = LogStash::Plugin.json("codec", "json").new
      @json.charset = "UTF-8"
   end

   def decode(data)
      @json.decode(data) do |i|
         puts i
         if i['resourceLogs']
            i['resourceLogs'].each do |resourceLog|
               resourceLog['scopeLogs'].each do |scopeLog|
                  scopeLog['logRecords'].each do |logRecord|
                     sv = logRecord['body']['stringValue']
                     puts sv
                     j = sv.from(sv.index('{')).to(sv.rindex('}')+1)
                     #j = sv[sv.index('{')..-(a.reverse.index('}')+1)];
                     puts j
                     if j.include?("}{")
                        JSON.parse("[#{j}]").each do |k|
                           puts k
                           yield LogStash::Event.new(k)
                        end
                     else
                        yield LogStash::Event.new(JSON.parse(j))
                     end
                  end
               end
            end
         else
            yield LogStash::Event.new(i)
         end
      end
   end # def decode

   # Encode a single event, this returns the raw data to be returned as a String
   def encode_sync(event)
      @json.encode(event)
   end # def encode_sync

end # class LogStash::Codecs::OtlpJson
