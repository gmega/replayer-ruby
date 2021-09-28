class SerializableDocumentSnapshot

  def initialize(document)
    @data = document.data
    @exists = document.exists?
  end

  def [](key)
    @data[key]
  end

  def exists?
    @exists
  end

  def ==(other)
    other.class == self.class &&
      other.data == self.data &&
      other.exists? == self.exists?
  end

  alias eql? ==

  def hash
    hash = 7
    hash = 31*hash + @data.hash
    31*hash + @exists.hash
  end

  protected

  attr_reader :data
end
