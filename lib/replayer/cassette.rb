require 'json'

module Replayer
  class Cassette

    # @return [Cassette]
    def self.from_file(path)
      Cassette.new(File.exist?(path) ? Marshal.load(File.read(path, mode: 'rb')) : nil)
    end

    def initialize(calls = nil)
      @is_recording = calls.nil?
      @calls = calls || Hash.new
    end

    def is_recording?
      @is_recording
    end

    def record(method, args, result)
      raise 'Cannot record new calls while in replay mode' unless is_recording?

      @calls[method] ||= []
      @calls[method] << MethodCall.new(args, result)

      result
    end

    def replay(method, args)
      raise 'Cannot replay calls while recording' if is_recording?

      match_call(method, args).result
    end

    def save(path)
      raise "Cannot save cassette when in replay mode" unless is_recording?

      File.open(path,  mode: 'wb') { |f| f.write(Marshal.dump(@calls)) }
    end

    private

    # @return [MethodCall]
    def match_call(method, args)
      matched, index = (@calls[method] || []).map.with_index.find { |call, _| call.matches?(args) }
      raise "Call to method #{method} could not be matched." if matched.nil?

      @calls[method].delete_at(index)
    end

  end

  class MethodCall

    attr_reader :result

    def initialize(args, result)
      @args = args
      @result = result
    end

    def matches?(args)
      return false if @args.length != args.length
      # TODO proper argument matching is a HUGE pain, but we'll have to get to it eventually. This
      # will break down but for the simplest of cases.
      args.map { |arg| @args.include? arg }.all?
    end
  end
end


