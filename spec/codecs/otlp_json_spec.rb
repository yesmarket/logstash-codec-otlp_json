# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/codecs/otlp_json"
require "logstash/codecs/json"
require "logstash/event"

describe LogStash::Codecs::OtlpJson do

   let(:options) { Hash.new }

   subject do
      LogStash::Codecs::OtlpJson.new(options)
   end

   shared_examples :codec do

      context "processing single logRecord with json message" do

         let(:json) { '{"resourceLogs":[{"resource":{},"scopeLogs":[{"scope":{},"logRecords":[{"observedTimeUnixNano":"1688598277293407428","body":{"stringValue":"{\"Timestamp\":\"2023-07-05T23:04:37.0985210+00:00\",\"Level\":\"Information\",\"MessageTemplate\":\"qwerty12345\",\"Properties\":{\"SourceContext\":\"dotnet_api.Controllers.StudentsController\",\"ActionId\":\"0c66b901-80ee-49d7-ac0f-3cb623e97c7d\",\"ActionName\":\"dotnet_api.Controllers.StudentsController.Get (dotnet-api)\",\"RequestId\":\"0HMRTLEV2ULDH:00000002\",\"RequestPath\":\"/api/v1/students/1\",\"ConnectionId\":\"0HMRTLEV2ULDH\",\"SpanId\":\"33583c8b7e163183\",\"TraceId\":\"c9a016f16f48d8f7427901c93ebba027\",\"ParentId\":\"1d50635029725adf\"}}"},"attributes":[{"key":"log.file.name","value":{"stringValue":"log20230705.txt"}}],"traceId":"","spanId":""}]}]}]}' }

         it "should yield single event" do
            count = 0
            subject.decode(json) do |event|
               expect( event.get("[root][MessageTemplate]") ).to eql 'qwerty12345'
               count += 1
            end
            expect(count).to eql(1)
         end

      end

      context "processing single logRecord with invalid json message" do

         let(:json) { '{"resourceLogs":[{"resource":{},"scopeLogs":[{"scope":{},"logRecords":[{"timeUnixNano":"1688598277000000000","observedTimeUnixNano":"1688598277330892906","severityNumber":9,"severityText":"info","body":{"stringValue":"\u003c134\u003eJul  5 23:04:37 localhost node[18]: {\"level\":\"info\",\"message\":\"asdfgh12345\",\"span_id\":\"a2c6a2e800953268\",\"timestamp\":\"2023-07-05T23:04:37.320Z\",\"trace_flags\":\"01\",\"trace_id\":\"93e41c63c6eacaab680f0a7a765e03b1\"}"},"attributes":[{"key":"proc_id","value":{"stringValue":"18"}},{"key":"priority","value":{"intValue":"134"}},{"key":"facility","value":{"intValue":"16"}},{"key":"hostname","value":{"stringValue":"localhost"}},{"key":"appname","value":{"stringValue":"node"}},{"key":"message","value":{"stringValue":"{\"level\":\"info\",\"message\":\"asdfgh12345\",\"span_id\":\"a2c6a2e800953268\",\"timestamp\":\"2023-07-05T23:04:37.320Z\",\"trace_flags\":\"01\",\"trace_id\":\"93e41c63c6eacaab680f0a7a765e03b1\"}"}}],"traceId":"","spanId":""}]}]}]}' }

         it "should yield single event" do
            count = 0
            subject.decode(json) do |event|
               expect( event.get("[root][message]") ).to eql 'asdfgh12345'
               count += 1
            end
            expect(count).to eql(1)
         end

      end

      context "processing multiple logRecords" do

         let(:json) { '{"resourceLogs":[{"resource":{},"scopeLogs":[{"scope":{},"logRecords":[{"observedTimeUnixNano":"1688598277293407428","body":{"stringValue":"{\"Timestamp\":\"2023-07-05T23:04:37.0985210+00:00\",\"Level\":\"Information\",\"MessageTemplate\":\"qwerty12345\",\"Properties\":{\"SourceContext\":\"dotnet_api.Controllers.StudentsController\",\"ActionId\":\"0c66b901-80ee-49d7-ac0f-3cb623e97c7d\",\"ActionName\":\"dotnet_api.Controllers.StudentsController.Get (dotnet-api)\",\"RequestId\":\"0HMRTLEV2ULDH:00000002\",\"RequestPath\":\"/api/v1/students/1\",\"ConnectionId\":\"0HMRTLEV2ULDH\",\"SpanId\":\"33583c8b7e163183\",\"TraceId\":\"c9a016f16f48d8f7427901c93ebba027\",\"ParentId\":\"1d50635029725adf\"}}"},"attributes":[{"key":"log.file.name","value":{"stringValue":"log20230705.txt"}}],"traceId":"","spanId":""},{"observedTimeUnixNano":"1688598277293414673","body":{"stringValue":"{\"Timestamp\":\"2023-07-05T23:04:37.2907908+00:00\",\"Level\":\"Information\",\"MessageTemplate\":\"qwerty12345\",\"Properties\":{\"SourceContext\":\"dotnet_api.Controllers.StudentsController\",\"ActionId\":\"0c66b901-80ee-49d7-ac0f-3cb623e97c7d\",\"ActionName\":\"dotnet_api.Controllers.StudentsController.Get (dotnet-api)\",\"RequestId\":\"0HMRTLEV2ULDI:00000002\",\"RequestPath\":\"/api/v1/students/1\",\"ConnectionId\":\"0HMRTLEV2ULDI\",\"SpanId\":\"5c4420a002d6c987\",\"TraceId\":\"93e41c63c6eacaab680f0a7a765e03b1\",\"ParentId\":\"76943c73f2bec60c\"}}"},"attributes":[{"key":"log.file.name","value":{"stringValue":"log20230705.txt"}}],"traceId":"","spanId":""}]}]}]}' }

         it "should yield multiple events" do
            count = 0
            subject.decode(json) do |event|
               count += 1
            end
            expect(count).to eql(2)
         end

      end

      context "processing single logRecord with multiple logs" do

         let(:json) { '{"resourceLogs":[{"resource":{},"scopeLogs":[{"scope":{},"logRecords":[{"observedTimeUnixNano":"1688598278119068238","body":{"stringValue":"{\"timestamp\":\"2023-07-05T23:04:35.421Z\",\"level\":\"INFO\",\"thread\":\"http-nio-5001-exec-3\",\"mdc\":{\"trace_id\":\"9e3cbaf255fe6ea6a7964cd859905557\",\"trace_flags\":\"01\",\"span_id\":\"c6d89e23862bbf21\"},\"logger\":\"com.demo.javaapi.controllers.StudentController\",\"message\":\"requested student with id: 1\",\"context\":\"default\"}{\"timestamp\":\"2023-07-05T23:04:35.683Z\",\"level\":\"INFO\",\"thread\":\"http-nio-5001-exec-5\",\"mdc\":{\"trace_id\":\"09ac6396ec6bfeee737b052d5146839c\",\"trace_flags\":\"01\",\"span_id\":\"c608cad9918228dc\"},\"logger\":\"com.demo.javaapi.controllers.StudentController\",\"message\":\"requested student with id: 1\",\"context\":\"default\"}"},"attributes":[{"key":"log.file.name","value":{"stringValue":"log.txt"}}],"traceId":"","spanId":""}]}]}]}' }

         it "should yield multiple events" do
            count = 0
            subject.decode(json) do |event|
               count += 1
            end
            expect(count).to eql(2)
         end

      end

      context "processing multiple resourceLogs" do

         let(:json) { '{"resourceLogs":[{"resource":{},"scopeLogs":[{"scope":{},"logRecords":[{"observedTimeUnixNano":"1688598277293407428","body":{"stringValue":"{\"Timestamp\":\"2023-07-05T23:04:37.0985210+00:00\",\"Level\":\"Information\",\"MessageTemplate\":\"qwerty12345\",\"Properties\":{\"SourceContext\":\"dotnet_api.Controllers.StudentsController\",\"ActionId\":\"0c66b901-80ee-49d7-ac0f-3cb623e97c7d\",\"ActionName\":\"dotnet_api.Controllers.StudentsController.Get (dotnet-api)\",\"RequestId\":\"0HMRTLEV2ULDH:00000002\",\"RequestPath\":\"/api/v1/students/1\",\"ConnectionId\":\"0HMRTLEV2ULDH\",\"SpanId\":\"33583c8b7e163183\",\"TraceId\":\"c9a016f16f48d8f7427901c93ebba027\",\"ParentId\":\"1d50635029725adf\"}}"},"attributes":[{"key":"log.file.name","value":{"stringValue":"log20230705.txt"}}],"traceId":"","spanId":""}]}]},{"resource":{},"scopeLogs":[{"scope":{},"logRecords":[{"observedTimeUnixNano":"1688598277293407428","body":{"stringValue":"{\"Timestamp\":\"2023-07-05T23:04:37.0985210+00:00\",\"Level\":\"Information\",\"MessageTemplate\":\"qwerty12345\",\"Properties\":{\"SourceContext\":\"dotnet_api.Controllers.StudentsController\",\"ActionId\":\"0c66b901-80ee-49d7-ac0f-3cb623e97c7d\",\"ActionName\":\"dotnet_api.Controllers.StudentsController.Get (dotnet-api)\",\"RequestId\":\"0HMRTLEV2ULDH:00000002\",\"RequestPath\":\"/api/v1/students/1\",\"ConnectionId\":\"0HMRTLEV2ULDH\",\"SpanId\":\"33583c8b7e163183\",\"TraceId\":\"c9a016f16f48d8f7427901c93ebba027\",\"ParentId\":\"1d50635029725adf\"}}"},"attributes":[{"key":"log.file.name","value":{"stringValue":"log20230705.txt"}}],"traceId":"","spanId":""}]}]}]}' }

         it "should yield multiple events" do
            count = 0
            subject.decode(json) do |event|
               count += 1
            end
            expect(count).to eql(2)
         end

      end

      context "processing multiple scopeLogs" do

         let(:json) { '{"resourceLogs":[{"resource":{},"scopeLogs":[{"scope":{},"logRecords":[{"observedTimeUnixNano":"1688598277293407428","body":{"stringValue":"{\"Timestamp\":\"2023-07-05T23:04:37.0985210+00:00\",\"Level\":\"Information\",\"MessageTemplate\":\"qwerty12345\",\"Properties\":{\"SourceContext\":\"dotnet_api.Controllers.StudentsController\",\"ActionId\":\"0c66b901-80ee-49d7-ac0f-3cb623e97c7d\",\"ActionName\":\"dotnet_api.Controllers.StudentsController.Get (dotnet-api)\",\"RequestId\":\"0HMRTLEV2ULDH:00000002\",\"RequestPath\":\"/api/v1/students/1\",\"ConnectionId\":\"0HMRTLEV2ULDH\",\"SpanId\":\"33583c8b7e163183\",\"TraceId\":\"c9a016f16f48d8f7427901c93ebba027\",\"ParentId\":\"1d50635029725adf\"}}"},"attributes":[{"key":"log.file.name","value":{"stringValue":"log20230705.txt"}}],"traceId":"","spanId":""}]},{"scope":{},"logRecords":[{"observedTimeUnixNano":"1688598277293407428","body":{"stringValue":"{\"Timestamp\":\"2023-07-05T23:04:37.0985210+00:00\",\"Level\":\"Information\",\"MessageTemplate\":\"qwerty12345\",\"Properties\":{\"SourceContext\":\"dotnet_api.Controllers.StudentsController\",\"ActionId\":\"0c66b901-80ee-49d7-ac0f-3cb623e97c7d\",\"ActionName\":\"dotnet_api.Controllers.StudentsController.Get (dotnet-api)\",\"RequestId\":\"0HMRTLEV2ULDH:00000002\",\"RequestPath\":\"/api/v1/students/1\",\"ConnectionId\":\"0HMRTLEV2ULDH\",\"SpanId\":\"33583c8b7e163183\",\"TraceId\":\"c9a016f16f48d8f7427901c93ebba027\",\"ParentId\":\"1d50635029725adf\"}}"},"attributes":[{"key":"log.file.name","value":{"stringValue":"log20230705.txt"}}],"traceId":"","spanId":""}]}]}]}' }

         it "should yield multiple events" do
            count = 0
            subject.decode(json) do |event|
               count += 1
            end
            expect(count).to eql(2)
         end

      end

   end

end
