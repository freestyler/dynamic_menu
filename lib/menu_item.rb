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
    item = Item.new(self, *args, &block)
    @items.push item
  end

  def remove(*args)
    @items.delete_if {|item| item.item_hash.include_hash?(args.first) }
  end

  def clear
    @items.clear
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
    @enabled ? true : false
  end

  protected

  def get_enabled(enabled)
    result_ary  = []
    temp_ary    = []
    if enabled.is_a?(Hash)
      result_ary << enabled_helper(enabled)
    elsif enabled.is_a?(Array)
      enabled.each do |enabled_item|
        if enabled_item.is_a?(Hash)
          result_ary << enabled_helper(enabled_item)
        end
      end
    end
    result_ary.include?(true)
  end

  private

  def enabled_helper(enabled)
    raise 'No hash argument' unless enabled.is_a?(Hash)
    temp_ary = []
    enabled.each do |key, value|
      temp_ary << if value.is_a?(Array)
                    value.map {|v| self.instance_variable_get("@#{key.to_s}".to_sym).to_s == v.to_s}.include?(true)
      else
        self.instance_variable_get("@#{key.to_s}".to_sym).to_s == value.to_s
      end
    end
    !temp_ary.include?(false)
  end

end
