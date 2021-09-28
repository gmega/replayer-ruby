# frozen_string_literal: true
require 'google/cloud/firestore'

Dir.glob(File.expand_path("firestore/*.rb", __dir__)).sort.each do |path|
  require path
end

module Replayer
  module Apps
    module Firestore
      extend self

      def enable
        QueryReplayer.enable
        DocumentReplayer.enable
      end

      def disabled
        DocumentReplayer.disable
        QueryReplayer.disable
      end
    end
  end
end