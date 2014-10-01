class Mobile::V1::NfcTagsController < ApiController
  before_filter :after_token_authentication
  
  # GET /mobile/:version/nfc_tags
  def index
    response = []
    current_user.nfc_tags.each do |tag|
      response.push({:id => tag.legible_id, :name => tag.name, :system_id => tag.id})
    end
    
    expose response
  rescue Exception => ex
    error! :bad_request, :metadata => {:error_description => ex.message}    
  end

  # POST /mobile/:version/nfc_tags
  def create
    tag_id = SecureRandom.hex(5)
    tag = current_user.nfc_tags.create!(:tag_id => tag_id)
    
    response = {:id => tag.legible_id, :name => 'Tag name', :system_id => tag.id}
    expose response
  rescue Exception => ex
    error! :bad_request, :metadata => {:error_description => ex.message}    
  end
  
  # PUT /mobile/:version/nfc_tags/:id
  # Can pass in the real id (generated by Rails), or set it to 0 and supply the tag_id
  def update
    if params[:tag_id].blank? and (0 == params[:id].to_i)
      error! :bad_request, :metadata => {:error_description => I18n.t('missing_argument', :arg => 'tag_id')}
    elsif params[:name].blank?  
      error! :bad_request, :metadata => {:error_description => I18n.t('missing_argument', :arg => 'name')}
    else
      tag = params[:tag_id].blank? ? current_user.nfc_tags.find_by_id(params[:id]) : 
                                     current_user.nfc_tags.find_by_tag_id(params[:tag_id].gsub('-', ''))
      
      if tag.nil?
        error! :not_found, :metadata => {:error_description => I18n.t('object_not_found', :obj => 'NFC Tag')}
      else
        begin 
          tag.update_attribute(:name, params[:name])
          head :ok
        rescue Exception => ex
          error! :bad_request, :metadata => {:error_description => ex.message} 
        end   
      end
    end    
  end
  
  # DELETE /mobile/:version/nfc_tags/:id
  # Can pass in the real id (generated by Rails), or set it to 0 and supply the tag_id
  def destroy
    if params[:tag_id].blank? and (0 == params[:id].to_i)
      error! :bad_request, :metadata => {:error_description => I18n.t('missing_argument', :arg => 'tag_id')}
    else
      tag = params[:tag_id].blank? ? current_user.nfc_tags.find_by_id(params[:id]) : 
                                     current_user.nfc_tags.find_by_tag_id(params[:tag_id].gsub('-', ''))
      
      if tag.nil?
        error! :not_found, :metadata => {:error_description => I18n.t('object_not_found', :obj => 'NFC Tag')}
      else
        tag.destroy
        head :ok
      end
    end
  end
end
