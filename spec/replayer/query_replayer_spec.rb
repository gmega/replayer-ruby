require 'spec_helper'
require 'google/cloud/firestore'

describe Replayer::Apps::Firestore::QueryReplayer do
  after(:each) {
    described_class.disable
  }

  it "is able to record/replay firestore queries" do
    def replayable_action
      client = Google::Cloud::Firestore.new(project_id: 'playax-lps')
      result_set = client.
        col('formResponses').
        where('timestamp', '>=', Date.new(2020, 1, 1)).
        get
      result_set.take(5)
    end

    described_class.enable

    # 1 - Record Action
    recorded = Replayer.insert_cassette('firestore_query') { replayable_action }

    expect(recorded.length).to be(5)
    # The fact the cassette exists means we're going to read it.
    expect(Replayer.cassette_exists?('firestore_query')).to be(true)

    # 2 - Replay Action
    replayed = Replayer.insert_cassette('firestore_query') { replayable_action }

    expect(recorded).to eq(replayed)
  end
end

