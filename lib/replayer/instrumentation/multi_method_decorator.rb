module Replayer
  module Instrumentation
    class MultiMethodDecorator

      def initialize(klass)
        @klass = klass
        @decorators = {}
      end

      def for_methods(*methods)
        methods.map do |method|
          next @decorators[method] if @decorators.has_key? method
          @decorators[method] = MethodDecorator.new(@klass, method)
        end
      end

      def clear
        @decorators.values.each(&:clear)
      end
    end
  end
end
