require 'core_ext'
require 'menu_item'
require 'render_menu_helper'

class DynamicMenu < MenuItem

  def initialize(*args, &block)
    options     = args.last.is_a?(Hash) ? args.pop : {}
    @controller = options[:controller]
    @action     = options[:action]
    @items      = []
    @parent     = nil
    block.call(self) if block_given?
  end

end

class Item < MenuItem

  def initialize(_parent, *args, &block)


    options = args.last.is_a?(Hash) ? args.pop : {}

    @items              = []
    @name               = options[:name] || args[0]
    @target             = options[:target] || args[1]
    @parent             = _parent
    @controller         = options[:controller] || @parent.controller
    @action             = options[:action] || @parent.action
    @enabled            = if enabled = options.delete(:enabled)
                            enabled if enabled.is_a?(TrueClass) or enabled.is_a?(FalseClass)
                            get_enabled(enabled) if enabled.is_a?(Hash) or enabled.is_a?(Array)
                          else
                            true
                          end
    @html_options       = options[:html_options] || {}

    options.each do |key, value|
      self.instance_variable_set("@#{key.to_s}".to_sym, value)
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
