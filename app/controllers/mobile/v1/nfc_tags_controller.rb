class Mobile::V1::NfcTagsController < ApiController
  before_filter :authenticate_user_from_token!
  
  # GET /mobile/:version/nfc_tags
  def index
    response = []
    current_user.nfc_tags.each do |tag|
      response.push({:id => tag.legible_id, :name => tag.name, :system_id => tag.id, :currency_id => tag.currency_id})
    end
    
    expose response
  rescue Exception => ex
    error! :bad_request, :metadata => {:error_description => ex.message, :user_error => I18n.t('tag_list_error') }    
  end

  # POST /mobile/:version/nfc_tags
  def create
    tag_id = SecureRandom.hex(5)
    tag = current_user.nfc_tags.create!(:tag_id => tag_id)
    
    response = {:id => tag.legible_id, :name => 'Tag name', :system_id => tag.id}
    expose response
  rescue Exception => ex
    error! :bad_request, :metadata => {:error_description => ex.message, :user_error => I18n.t('tag_create_error') }    
  end
  
  # PUT /mobile/:version/nfc_tags/:id
  # Can pass in the real id (generated by Rails), or set it to 0 and supply the tag_id
  def update
    if params[:tag_id].blank? and (0 == params[:id].to_i)
      error! :bad_request, :metadata => {:error_description => I18n.t('missing_argument', :arg => 'tag_id'), :user_error => I18n.t('tag_update_error') }
    elsif params[:name].blank?  
      error! :bad_request, :metadata => {:error_description => I18n.t('missing_argument', :arg => 'name'), :user_error => I18n.t('tag_update_error') }
    else
      tag = params[:tag_id].blank? ? current_user.nfc_tags.find_by_id(params[:id]) : 
                                     current_user.nfc_tags.find_by_tag_id(params[:tag_id].gsub('-', ''))
      
      if tag.nil?
        error! :not_found, :metadata => {:error_description => I18n.t('object_not_found', :obj => 'NFC Tag'), :user_error => I18n.t('invalid_tag') }
      else
        begin 
          tag.update_attribute(:name, params[:name])
          head :ok
        rescue Exception => ex
          error! :bad_request, :metadata => {:error_description => ex.message, :user_error => I18n.t('tag_update_error') } 
        end   
      end
    end    
  end
  
  # DELETE /mobile/:version/nfc_tags/:id
  # Can pass in the real id (generated by Rails), or set it to 0 and supply the tag_id
  def destroy
    if params[:tag_id].blank? and (0 == params[:id].to_i)
      error! :bad_request, :metadata => {:error_description => I18n.t('missing_argument', :arg => 'tag_id'), :user_error => I18n.t('invalid_tag') }
    else
      tag = params[:tag_id].blank? ? current_user.nfc_tags.find_by_id(params[:id]) : 
                                     current_user.nfc_tags.find_by_tag_id(params[:tag_id].gsub('-', ''))
      
      if tag.nil?
        error! :not_found, :metadata => {:error_description => I18n.t('object_not_found', :obj => 'NFC Tag'), :user_error => I18n.t('invalid_tag') }
      else
        tag.destroy
        head :ok
      end
    end
  end
end
