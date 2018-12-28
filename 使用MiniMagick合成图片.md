```
tags:MiniMagick
```
  ## 合并图片
  ```ruby
  def merged_images(images_name,id,width,height,upper_left_position)
    old =  Rails.root.join("app/assets/images/old.png")
    new_img = Rails.root.join("public/uploads/ad/picture/#{id}/#{images_name}")
    first_image  = MiniMagick::Image.new(old.to_s)
    second_image = MiniMagick::Image.new(new_img.to_s)
    p "原始图片大小===== #{second_image.width},#{second_image.height}"
    p "图片合并====== #{width}X#{height}+#{upper_left_position[0]}+#{upper_left_position[1]}"
    result = first_image.composite(second_image) do |c|
      c.compose "Over"
      c.geometry "#{width}X#{height}+#{upper_left_position[0]}+#{upper_left_position[1]}"
    end
    result.write Rails.root.join("app/assets/images/new.png").to_s
    result.write Rails.root.join("app/assets/images/old.png").to_s
  end
  ```
<!--more-->
  ## 生成图片
  ```ruby
  
  def create_new_init_image(width,height,image_name,path)
    MiniMagick::Tool::Convert.new do |i|
      i.size "#{width}X#{height}"
      i.gravity "center"
      i.xc "#c9c9c9"
      i << "#{path}init-#{image_name}"
    end
  end
  ```