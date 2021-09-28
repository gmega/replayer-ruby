module Replayer
  module Apps
    module Firestore
      class DocumentReplayer

        @decorator = Instrumentation::MethodDecorator.new(Google::Cloud::Firestore::DocumentReference, :get)

        def self.enable
          @decorator.decorate do |next_method, *args, &block|
            SerializableDocumentSnapshot.new(next_method.call(*args, &block))
          end
          Replayer.install(Google::Cloud::Firestore::DocumentReference, :get)
        end

        def self.disable
          Replayer.uninstall(Google::Cloud::Firestore::DocumentReference)
          @decorator.clear
        end
      end
    end
  end
end