module ActionView
  class Base

    def render_menu(dynamic_menu)
      raise 'No DynamicMenu or Item Object' unless dynamic_menu.instance_of?(DynamicMenu) or dynamic_menu.instance_of?(Item)
      
      content_tag :ul do
        dynamic_menu.items.map do |menu_item|
          content_tag :li, (link_to menu_item[:name], menu_item[:target]) + (menu_item.items.empty? ? '' : render_menu(menu_item))
        end.flatten.compact.join
      end
    end

  end
end
