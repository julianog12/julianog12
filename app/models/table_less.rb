class TableLess < ApplicationRecord

  self.abstract_class = true

  def self.attribute_names
    @attribute_names ||= attribute_types.keys
  end

  def self.load_schema!
    @columns_hash ||= Hash.new

    # From active_record/attributes.rb
    attributes_to_define_after_schema_loads.each do |name, (type, options)|
      if type.is_a?(Symbol)
        type = ActiveRecord::Type.lookup(type, **options.except(:default))
      end

      define_attribute(name, type, **options.slice(:default))

      # Improve Model#inspect output
      @columns_hash[name.to_s] = ActiveRecord::ConnectionAdapters::Column.new(name.to_s, options[:default])
    end

    # Apply serialize decorators
    attribute_types.each do |name, type|
      decorated_type = attribute_type_decorations.apply(name, type)
      define_attribute(name, decorated_type)
    end
  end

  def persisted?
    false
  end
end
