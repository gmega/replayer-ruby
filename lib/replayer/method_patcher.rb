module Replayer

  class MethodPatcher
    def initialize(klass, replayer)
      @klass = klass
      @replayer = replayer
      @patches = {}
    end

    def for_methods(*method_list)
      method_list.each do |method|
        @patches[method] = patch_method(method)
      end
    end

    def revert
      @patches.each { |method_name, method| @klass.define_method(method_name, method) }
    end

    private

    def patch_method(method)
      unwrapped = @klass.instance_method(method)
      replayer = @replayer

      @klass.define_method(method) do |*args, &block|
        cassette = replayer.current_cassette
        raise 'No cassette has been inserted!' if cassette.nil?

        if cassette.is_recording?
          cassette.record(method, args, unwrapped.bind(self).call(*args, &block))
        else
          cassette.replay(method, args)
        end
      end

      unwrapped
    end
  end
end