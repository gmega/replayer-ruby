require 'spec_helper'
require 'google/cloud/firestore'

describe Replayer do
  context "firestore client" do
    let(:since) { Date.new(2020, 1, 1) }

    after(:each) {
      Replayer::Firestore::QueryReplayer.disable
    }

    it "is able to replay calls to the client" do
      Replayer::Firestore::QueryReplayer.enable

      recorded = Replayer.insert_cassette('firestore_query') do
        client = Google::Cloud::Firestore.new(project_id: 'playax-lps')
        result_set = client.col('formResponses').where('timestamp', '>=', since).get
        result_set.take(5)
      end

      # The fact the cassette exists means we're going to read it.
      expect(Replayer.cassette_exists?('firestore_query')).to be(true)

      replayed = Replayer.insert_cassette('firestore_query') do
        client = Google::Cloud::Firestore.new(project_id: 'playax-lps')
        result_set = client.col('formResponses').where('timestamp', '>=', since).get
        result_set.take(5)
      end

      expect(recorded).to eq(replayed)
    end
  end
end

