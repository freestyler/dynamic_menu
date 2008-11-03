class MenuItem

  attr_reader :name
  attr_reader :items
  attr_reader :target

  def [](attribute)
    instance_variable_get("@#{attribute}".to_sym)
  end

  def []=(attribute, value)
    instance_variable_set("@#{attribute}".to_sym, value)
  end

  def add(*args, &block)
    item = DynamicMenu.new(self, *args, &block)
    @items.push item
  end

  def level
    i = 1
    s_p = self.parent
    while s_p = s_p.parent
      i += 1
    end
    i
  end

  def enabled?
    @enabled
  end

  def active?
    @active
  end

  def active_item
    self.items.find { |item| item.active? }
  end

  def position
    self[:parent].items.index(self)
  end

  def next
    return nil if self[:parent].items.last == self
    self[:parent].items.at(self.position + 1)
  end

  def previous
    return nil if self[:parent].items.first == self
    self[:parent].items.at(self.position - 1)
  end

  alias :prev :previous

  protected

  def get_property(property)
    result_ary  = []
    temp_ary    = []
    if property.is_a?(Hash)
      result_ary << property_helper(property)
    elsif property.is_a?(Array)
      property.each do |property_item|
        if property_item.is_a?(Hash)
          result_ary << property_helper(property_item)
        end
      end
    end
    result_ary.include?(true)
  end

  def parents
    ([] << self[:parent] << (self[:parent] ? self[:parent].parents : nil)).flatten.compact
  end

  def self_with_parents
    [self, self.parents].flatten.compact
  end

  private

  def property_helper(property)
    raise 'No hash argument' unless property.is_a?(Hash)
    temp_ary = []
    property.each do |key, value|
      temp_ary << if value.is_a?(Array)
                    value.map {|v| self.self_with_parents.map { |item| item[key.to_sym].to_s == v.to_s } }.flatten.compact.include?(true)
      else
        self.self_with_parents.map { |item| item[key.to_sym].to_s == value.to_s }.include?(true)
      end
    end
    !temp_ary.include?(false)
  end

end
