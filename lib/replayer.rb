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
        block.call
      ensure
        eject
      end
    end
  end

  def eject(save: nil)
    if save.nil?
      # If the user doesn't say anything, we'll save only if recording.
      @cassette.save if @cassette.is_recording?
    elsif save
      # If the user explicitly says we should save, we try to save.
      @cassette.save
    end
    # If the user explicitly says we should NOT save, we don't save.

    @cassette = nil
  end

  def current_cassette
    @cassette
  end

  def cassette_inserted?
    !current_cassette.nil?
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
