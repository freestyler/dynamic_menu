require 'core_ext'
require 'menu_item'

class DynamicMenu < MenuItem

  def initialize(*args, &block)
   
    _parent = args.first.is_a?(DynamicMenu) ? args.delete_at(0) : nil

    options = args.last.is_a?(Hash) ? args.pop : {}
    
    @parent             = _parent
    @items              = []
    @name               = options.delete(:name) || args[0]
    @target             = options.delete(:target) || args[1]
    @html_options       = {}

    @enabled            = if enabled = options.delete(:enabled)
                            enabled if enabled.is_a?(TrueClass) or enabled.is_a?(FalseClass)
                            get_property(enabled) if enabled.is_a?(Hash) or enabled.is_a?(Array)
                          else
                            true
                          end

    @active            =  if active = options.delete(:active)
                            active if active.is_a?(TrueClass) or active.is_a?(FalseClass)
                            get_property(active) if active.is_a?(Hash) or active.is_a?(Array)
                          else
                            false
                          end

    options.each do |key, value|
      self[key.to_sym] = value
    end

    if @active
      self[:html_options][:class].blank? ? (self[:html_options][:class] = (@active_class || 'active')) : (self[:html_options][:class] += ' ' + (@active_class || 'active'))
    end
    yield(self) if block_given?
  end

end
