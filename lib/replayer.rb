require 'replayer/method_patcher'
require 'replayer/cassette'
require 'replayer/firestore'
require 'replayer/version'

module Replayer
  extend self

  @cassette = nil
  @patches = {}

  def configure
    yield self
  end

  def cassette_folder=(folder)
    @cassette_folder = folder
  end

  def cassette_exists?(name)
    File.exists?(cassette_file(name))
  end

  def insert_cassette(name, &block)
    path = cassette_file(name)
    @cassette = Cassette.from_file(path)

    # Block form automatically calls eject at the end.
    if block_given?
      begin
        result = block.call
        @cassette.save(path) if @cassette.is_recording?
        result
      ensure
        eject
      end
    end
  end

  def eject
    @cassette = nil
  end

  def current_cassette
    @cassette
  end

  def attach(klass)
    patcher = @patches[klass]
    if patcher.nil?
      patcher = MethodPatcher.new(klass, self)
      @patches[klass] = patcher
    end
    patcher
  end

  def detach(klass = nil)
    if klass.nil?
      @patches.values.each(&:revert)
      return
    end

    @patches[klass]&.revert
  end

  def use_firestore_shim
    require 'replayer/firestore'
  end

  private

  def cassette_file(name)
    File.join(@cassette_folder, name)
  end
end
