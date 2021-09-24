require 'spec_helper'

class Generator
  def generate
    rand
  end
end

class GeneratorWithArgs < Generator
  def generate_multi(n, offset: 0)
    (1..n).map { generate + offset }
  end
end


describe Replayer do

  after(:each) do
    Replayer.detach
  end

  it "record/replays basic cases" do
    Replayer.
      attach(Generator).
      for_methods(:generate)

    recorded = Replayer.insert_cassette('basic_cases') { Generator.new.generate }
    replayed = Replayer.insert_cassette('basic_cases') { Generator.new.generate }

    expect(recorded).to eq(replayed)
  end

  it 'record/replays with simple args' do
    Replayer.
      attach(GeneratorWithArgs).
      for_methods(:generate_multi)

    recorded = Replayer.insert_cassette('simple_args') { GeneratorWithArgs.new.generate_multi(10, offset: 2) }
    replayed = Replayer.insert_cassette('simple_args') { GeneratorWithArgs.new.generate_multi(10, offset: 2) }

    expect(recorded.length).to be(10)
    expect(recorded).to eq(replayed)
  end

  it 'correctly record/replays multiple calls to same method' do
    Replayer.
      attach(Generator).
      for_methods(:generate)

    recorded = Replayer.insert_cassette('multiple_calls') { GeneratorWithArgs.new.generate_multi(10, offset: 2) }
    replayed = Replayer.insert_cassette('multiple_calls') { GeneratorWithArgs.new.generate_multi(10, offset: 2) }

    expect(recorded.length).to be(10)
    expect(recorded).to eq(replayed)
  end

end