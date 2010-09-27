module ApplicationHelper
  # Return a title on a per-page basis.
  def logo
    image_tag("logo.jpg", :alt => "PostBook", :class => "round")
  end
  def title
    base_title = "PostBook App"
    if @title.nil?
      base_title
    else 
      "#{base_title} | #{@title}"
    end
  end
end
