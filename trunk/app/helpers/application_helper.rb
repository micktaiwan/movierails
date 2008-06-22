# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def self.generate_key
    str = ''; 30.times { str += (rand(26)+65).chr }; str
  end

  def my_text_field_with_auto_complete(object, method, tag_options = {}, completion_options = {})
    if(tag_options[:id])
      tag_name = "#{tag_options[:id]}"
    else
      tag_name = "#{object}_#{method}"
    end

    (completion_options[:skip_style] ? "" : auto_complete_stylesheet) +
        text_field(object, method, tag_options) +
        content_tag("div", "", :id => tag_name + "_auto_complete", :class => "auto_complete") +
        auto_complete_field(tag_name,
        { :url => { :action => "auto_complete_for_#{object}_#{method}" }
        }.update(completion_options))
  end
  
end
