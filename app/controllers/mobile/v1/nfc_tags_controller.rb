class Mobile::V1::NfcTagsController < ApiController
  before_filter :after_token_authentication

  def index
    response = []
    current_user.nfc_tags.each do |tag|
      response.push({:id => tag.legible_id, :name => tag.name})
    end
    
    expose response
  rescue Exception => ex
    error! :bad_request, :metadata => {:error_description => ex.message}    
  end

  def create
    tag_id = SecureRandom.hex(5)
    tag = current_user.nfc_tags.create!(:tag_id => tag_id)
    
    response = {:id => tag.legible_id, :name => 'Tag name'}
    expose response
  rescue Exception => ex
    error! :bad_request, :metadata => {:error_description => ex.message}    
  end
  
  def update
    if params[:tag_id].blank?
      error! :bad_request, :metadata => {:error_description => I18n.t('missing_argument', :arg => 'tag_id')}
    elsif params[:name].blank?  
      error! :bad_request, :metadata => {:error_description => I18n.t('missing_argument', :arg => 'name')}
    else
      tag = current_user.nfc_tags.find_by_tag_id(params[:tag_id])
      
      if tag.nil?
        error! :not_found, :metadata => {:error_description => I18n.t('object_not_found', :obj => 'NFC Tag')}
      else
        tag.update_attribute(:name, params[:name])
        head :ok
      end
    end
    
  rescue Exception => ex
    error! :bad_request, :metadata => {:error_description => ex.message}    
  end
end
