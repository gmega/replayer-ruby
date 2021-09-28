describe Replayer::Apps::Firestore::DocumentReplayer do

  after(:each) {
    Replayer::Apps::Firestore::QueryReplayer.disable
    described_class.disable
  }

  it "is able to record/replay firestore document fetches" do

    def replayable_action
      client = Google::Cloud::Firestore.new(project_id: 'playax-lps')
      tokens = client.
        col('formResponses').
        where('timestamp', '>=', Date.new(2020, 1, 1)).
        get

      seen = Set.new
      tokens.map do |fs_token|
        page_id = fs_token[:pageId] || fs_token[:formId]
        next if seen.include?(page_id)
        document = client.col('pages').doc(page_id).get
        seen.add(page_id)
        puts page_id
        document
      end
    end

    Replayer::Apps::Firestore::QueryReplayer.enable
    described_class.enable

    recorded_docs = Replayer.insert_cassette('firestore_query') { replayable_action }
    replayed_docs = Replayer.insert_cassette('firestore_query') { replayable_action }

    expect(recorded_docs).to eq(replayed_docs)
  end
end

