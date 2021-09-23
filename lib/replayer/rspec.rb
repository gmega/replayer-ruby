=begin
module Recorder
  class RSpec
    def self.attach_to_rspec!
      ::Rspec.configure do |config|
        when_tagged_with_recorder = { :recorder => lambda { |v| !!v } }

        config.before(:each, when_tagged_with_recorder) do |example|
          example = example.respond_to?(:metadata) ? example : example.example
          Replayer.insert_cassette(self.cassette_name_for(example.metadata))
        end
      end

      def self.cassette_name_for(metadata)
        description =
          if metadata[:description].empty?
            # we have an "it { is_expected.to be something }" block
            metadata[:scoped_id]
          else
            metadata[:description]
          end
        example_group =
          if metadata.key?(:example_group)
            metadata[:example_group]
          else
            metadata[:parent_example_group]
          end

        if example_group
          [cassette_name_for(example_group), description].join('/')
        else
          description
        end
      end
    end
  end
end=end
