module Replayer
  module Instrumentation
    class MethodDecorator

      attr_reader :method_name, :original_method

      def initialize(klass, method_name)
        @klass = klass
        @original_method = klass.instance_method(method_name)
        @method_name = method_name
      end

      def decorate(&decoration)
        next_method = @klass.instance_method(@method_name)
        @klass.define_method(method_name) do |*args, &block|
          # Decorators always get the next function in the chain as their first argument.
          Instrumentation.rebind_proc(decoration, self).call(next_method.bind(self), *args, &block)
        end
      end

      def clear
        @klass.define_method(@method_name, @original_method)
      end
    end
  end
end
