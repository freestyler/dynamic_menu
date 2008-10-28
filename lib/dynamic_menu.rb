require 'core_ext'
require 'menu_item'
require 'render_menu_helper'

class DynamicMenu < MenuItem

  def initialize(*args, &block)
    options     = args.last.is_a?(Hash) ? args.pop : {}
    
    @items        = []
    @parent       = nil
    @html_options = {}
    
    options.each do |key, value|
      self.instance_variable_set("@#{key.to_s}".to_sym, value)
    end

    block.call(self) if block_given?
  end

end

class Item < MenuItem

  def initialize(_parent, *args, &block)


    options = args.last.is_a?(Hash) ? args.pop : {}

    _parent.instance_variables.each do |i_v|
      self.instance_variable_set(i_v.to_sym, _parent.instance_variable_get(i_v.to_sym))
    end

    @parent             = _parent

    @items              = []
    
    @name               = options.delete(:name) || args[0]
    @target             = options.delete(:target) || args[1]

    options.each do |key, value|
      self.instance_variable_set("@#{key.to_s}".to_sym, value)
    end

    @enabled            = if enabled = options.delete(:enabled)
                            enabled if enabled.is_a?(TrueClass) or enabled.is_a?(FalseClass)
                            get_enabled(enabled) if enabled.is_a?(Hash) or enabled.is_a?(Array)
                          else
                            true
                          end

    @active            =  if active = options.delete(:active)
                            active if active.is_a?(TrueClass) or active.is_a?(FalseClass)
                            get_active(active) if active.is_a?(Hash) or active.is_a?(Array)
                          else
                            false
                          end

    if @active
      self[:html_options][:class].blank? ? (self[:html_options][:class] = (@active_class || 'active')) : (self[:html_options][:class] += ' ' + (@active_class || 'active'))
    end

    block.call(self) if block_given?

  end

  def item_hash
    result = {}
    self.instance_variables.each do |i_v|
      result.merge!(i_v[1..-1].to_sym => self.instance_variable_get(i_v.to_sym))
    end
    result
  end

end
