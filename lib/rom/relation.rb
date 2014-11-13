require 'charlatan'

module ROM

  class Relation
    include Charlatan.new(:dataset)

    undef_method :select

    attr_reader :header
    attr_reader :adapter_inclusions, :adapter_extensions

    def initialize(dataset, header = dataset.header)
      super
      @header = header.dup.freeze
      @adapter_inclusions = []
      @adapter_extensions = []
    end

    def each(&block)
      return to_enum unless block
      dataset.each(&block)
    end

    def insert(tuple)
      dataset.insert(tuple)
      self
    end

    def update(tuple)
      dataset.update(tuple)
      self
    end

    def delete
      dataset.delete
      self
    end

  end

end
