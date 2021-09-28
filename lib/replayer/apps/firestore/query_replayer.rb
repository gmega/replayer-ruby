module Replayer
  module Apps
    module Firestore
      class QueryReplayer
        @decorator = Instrumentation::MethodDecorator.new(Google::Cloud::Firestore::Query, :get)

        def self.enable
          @decorator.decorate do |_, &block|
            # Google's firestore client actually uses the :get method both to return
            # the results enumerable, and then later as the ":each" method of the
            # enumerable it returned.

            # To avoid complications, we eagerly load results from the get and transform
            # it into a serializable array. Other approaches are possible, but at the cost
            # of significant complexity.

            # When block is nil, this is the first call to get. We return an enumerable and
            # eagerly call to_a. This will cause get to be called again with a block, which
            # we'll then pass to the overridden method.
            return (enum_for :get_element).
              to_a.
              map { |doc| SerializableDocumentSnapshot.new(doc) } if block.nil?

            # FIXME :get will match any call regardless of the query.
          end

          Google::Cloud::Firestore::Query.define_method(:get_element, @decorator.original_method)
          Replayer.install(Google::Cloud::Firestore::Query, :get)
        end

        def self.disable
          Replayer.uninstall(Google::Cloud::Firestore::Query)
          Google::Cloud::Firestore::Query.undef_method(:get_element)
          @decorator.clear
        end
      end
    end
  end
end