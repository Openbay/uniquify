# NOTE AB: Removed the ability to run custom blocks and added ability to omit
# certain characters from the character library.
#
module Uniquify
  def self.included(base)
    base.extend ClassMethods
    base.include InstanceMethods
  end

  module ClassMethods
    def uniquify(attrs, options={})
      [attrs].flatten.each do |name|
        before_validation :on => :create do |record|
          record._ensure_unique(name) { Uniquify::Base.generate(options) }
        end
      end
    end
  end

  module InstanceMethods
    def _ensure_unique(name)
      begin
        self[name] = yield
      end while self.class.exists?(name => self[name])
    end
  end

  class Base
    attr_accessor :options

    def self.generate(options={})
      new(options).generate
    end

    def initialize(options={})
      @options = default_options.merge(options)
      remove_omitted_chars
    end

    def default_options
      { :length => 8, 
        :chars => ('a'..'z').to_a + ('0'..'9').to_a, 
        :omit => [] }
    end

    def remove_omitted_chars
      options[:chars].reject!{|char| options[:omit].include?(char)}
    end

    def generate
      Array.new(options[:length]) { random_char }.join
    end

    def random_char
      options[:chars].to_a[rand(options[:chars].to_a.size)]
    end
  end
end

