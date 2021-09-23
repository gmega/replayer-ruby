require 'google/cloud/firestore'

module Replayer
  module Firestore
    class QueryReplayer
      @query_get = Google::Cloud::Firestore::Query.instance_method(:get)

      def self.enable
        Google::Cloud::Firestore::Query.define_method(:get) do |&block|
          # Google's firestore client actually uses the :get method both to return
          # the results enumerable, and then later as the ":each" method of the
          # enumerable it returned.

          # To avoid complications, we eagerly load results from the get and transform
          # it into a serializable array. Other approaches are possible, but at the cost
          # of significant complexity.

          # When block is nil, this is the first call to get. We return an enumerable and
          # eagerly call to_a. This will cause get to be called again with a block, which
          # we'll then pass to the overridden method.
          return JSONEnumerable.new((enum_for :get_element).to_a.map(&:data)) if block.nil?

          # FIXME :get will match any call regardless of the query.
        end

        Google::Cloud::Firestore::Query.define_method(:get_element, @query_get)
        Replayer.attach(Google::Cloud::Firestore::Query).for_methods(:get)
      end

      def self.disable
        Replayer.detach(Google::Cloud::Firestore::Query)
        Google::Cloud::Firestore::Query.undef_method(:get_element)
        Google::Cloud::Firestore::Query.define_method(:get, @query_get)
      end
    end

    class JSONEnumerable
      include Enumerable

      def initialize(elements)
        @elements = elements
      end

      def each(&block)
        @elements.each(&block)
      end
    end
  end
end
