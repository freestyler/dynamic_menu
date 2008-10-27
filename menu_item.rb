class MenuItem

  def [](attribute)
    instance_variable_get("@#{attribute}".to_sym)
  end

  def []=(attribute, value)
    instance_variable_set("@#{attribute}".to_sym, value)
  end

  def items
    @items
  end

  def add(*args, &block)
    item = Item.new(*args, &block)
    item[:parent] = self
    @items << item
  end

  def remove(*args)
    @items.delete_if {|item| item.item_hash.include?(args.first) }
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

  def target
    parent and parent.target_completion ? (parent[:target] + "#{self[:target]}") : self[:target]
  end

end


