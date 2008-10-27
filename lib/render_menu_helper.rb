module ActionView
  class Base

    def render_menu(dynamic_menu, *args)
      raise 'No DynamicMenu or Item Object' unless dynamic_menu.instance_of?(DynamicMenu) or dynamic_menu.instance_of?(Item)
      options = args.last.is_a?(Hash) ? args.last : {}
      model = options[:model] || [:ul, :li]
      
      content_tag model.first do
        dynamic_menu.items.map do |menu_item|
          content_tag model.last, (link_to menu_item[:name], menu_item[:target]) + (menu_item.items.empty? ? '' : render_menu(menu_item, *args))
        end
      end
    end

  end
end
