require 'replayer/instrumentation/method_decorator'
require 'replayer/instrumentation/multi_method_decorator'

module Replayer
  module Instrumentation
    extend self

    def rebind_proc(block, object)
      klass = object.singleton_class
      time = Time.now
      method_name = "__temp_#{time.to_i}_#{time.usec}"
      klass.define_method(method_name, &block)
      method = klass.instance_method(method_name)
      method.bind(object)
    ensure
      klass.remove_method(method_name) if defined? method_name
    end

  end
end
