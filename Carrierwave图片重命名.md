```
tags:gem,Carrierwave
```
### Uploader
```ruby
class PictureUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    %w(jpg jpeg png)
  end
  def filename
    @name ||= "#{timestamp}-#{super}" if original_filename.present? and super.present?
  end

  def timestamp
    var = :"@#{mounted_as}_timestamp"
    model.instance_variable_get(var) or model.instance_variable_set(var, Time.now.to_i)
  end
end
```
<!--more-->
<hr>

 ```ruby   
class PictureUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    %w(jpg jpeg png)
  end

  def filename
    if original_filename
      # current_path 是 Carrierwave 上传过程临时创建的一个文件，有时间标记
      @name ||= Digest::MD5.hexdigest(current_path)
      "#{@name}.#{file.extension}"
    end
  end
end

```
### Controller
```ruby
class AdsController < ApplicationController
  include AdsHelper
  def update
    id = params[:id]
    block = Block.find_by(id: id)
    block.ad.update(ad_params)
    block.ad.update(status: 0,status_update_at:Time.new)
    ## 获取picture的名字
    images_name = block.ad.picture_identifier
    width = block.width
    height = block.height
    p images_name,id,width,height
    if picture_ratio?(images_name,id,width,height)
      render js:"alert('Update Fails! Picture ratio error！')"
    else
      render js:"alert('Update Success! Waiting for review!')"
    end
  end
 end
```