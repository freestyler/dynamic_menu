module DynamicMenu

  class MenuItem
    attr_reader :name
    attr_reader :items
    attr_reader :target

    def [](attribute); instance_variable_get("@#{attribute}".to_sym); end
    def []=(attribute, value); instance_variable_set("@#{attribute}".to_sym, value); end

    def self_or_inherited_attribute(attribute)
      attribute = attribute.to_sym
      self[attribute] or (self[:parent] and self[:parent].self_or_inherited_attribute(attribute)) or nil
    end

    def add(*args, &block)
      item = DynamicMenu.new(self, *args, &block)
      @items.push item
    end

    def active?; @active; end
    def active_item; self.items.find { |item| item.active? }; end
    def position; self[:parent].items.index(self); end

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

    def url
      self_or_inherited_attribute(:url)
    end

    def method
      self_or_inherited_attribute(:method)
    end

    def current_page?(_target, _method)
      !url.match(_target.is_a?(String) ? Regexp.new(_target.gsub('?', '\?') + '$').gsub('+', "\\\\+") + '$') : Regexp.new(_target.source + '$')) and method == _method.to_s
    end

  end

  class DynamicMenu < MenuItem

    def initialize(*args, &block)

      _parent     = args[0].is_a?(DynamicMenu) ? args.delete_at(0) : nil
      if kontroller = (args[0].is_a?(ActionController::Base) ? args.delete_at(0) : nil)
        request = kontroller.request
        @url = "#{request.protocol}#{request.host_with_port}#{request.request_uri}"
        @method = request.request_method.to_s
      end

      options = args.last.is_a?(Hash) ? args.pop : {}

      @parent             = _parent
      @items              = []
      @name               = options.delete(:name)         || args[0]
      @target             = options.delete(:target)       || args[1]
      @targets            = options.delete(:targets)      || [args[2]].flatten
      @active             = options.delete(:active)
      
      @html_options       = {}

      options.each { |key, value| self[key.to_sym] = value }

      yield(self) if block_given?

      @active = @active || [[@target] + @targets].flatten.compact.map { |target|
                    if target.is_a?(String) or target.is_a?(Regexp)
                      url     = target
                      method  = :get
                    elsif target.is_a?(Hash)
                      url     = target[:url]
                      method  = target[:method] || :get
                    end
                    current_page?(url, method)
                  }.include?(true)

      if @active
        self[:html_options][:class].blank? ? (self[:html_options][:class] = (@active_class || 'active')) : (self[:html_options][:class] += ' ' + (@active_class || 'active'))
      end

    end

  end

  def dynamic_menu(*args, &block)
    DynamicMenu.new(self, *args, &block)
  end
end
