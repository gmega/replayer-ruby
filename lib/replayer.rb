require 'replayer/instrumentation'
require 'replayer/cassette'
require 'replayer/apps'
require 'replayer/version'

module Replayer
  extend self

  @cassette = nil
  @patched = {}

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

  def install(klass, *methods)
    decorator(klass).
      for_methods(*methods).
      each { |decorator| decorator.decorate(&replay_decorator(decorator.method_name)) }
  end

  def uninstall(klass = nil)
    if klass.nil?
      @patched.values.each(&:clear)
      return
    end

    @patched[klass]&.clear
  end

  # Returns the {Replayer::MultimethodDecorator} used by {Replayer} to instrument class methods.
  # Clients can use such decorators to insert their own instrumentation in methods and transforming
  # data before calling {#install}.
  #
  # This method is not a part of the public API.
  def decorator(klass)
    patcher = @patched[klass]
    if patcher.nil?
      patcher = Instrumentation::MultiMethodDecorator.new(klass)
      @patched[klass] = patcher
    end
    patcher
  end

  private

  def cassette_file(name)
    File.join(@cassette_folder, name)
  end

  def replay_decorator(method)
    self_replayer = self

    Proc.new do |next_method, *args, &block|
      cassette = self_replayer.current_cassette
      raise 'No cassette has been inserted!' if cassette.nil?

      if cassette.is_recording?
        cassette.record(method, args, next_method.call(*args, &block))
      else
        cassette.replay(method, args)
      end
    end
  end
end
