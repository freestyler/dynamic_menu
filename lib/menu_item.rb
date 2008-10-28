class MenuItem

  attr_reader :name
  attr_reader :items
  attr_reader :controller
  attr_reader :action
  attr_reader :target

  def [](attribute)
    instance_variable_get("@#{attribute}".to_sym)
  end

  def []=(attribute, value)
    instance_variable_set("@#{attribute}".to_sym, value)
  end

  def add(*args, &block)
    item = Item.new(self, *args, &block)
    @items << item
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
    if enabled.is_a?(Hash) and enabled.has_key?(:controller) and enabled.has_key?(:action)
      controller == enabled[:controller].to_s and (action == enabled[:action].to_s or enabled[:action].to_s == 'all')
    else
      false
    end
  end

end
