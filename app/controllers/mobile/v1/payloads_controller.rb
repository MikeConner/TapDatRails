class Mobile::V1::PayloadsController < ApiController
  before_filter :authenticate_user_from_token!
  before_filter :ensure_own_tag, :except => [:show]
  
  # GET /mobile/:version/payloads
  # Must pass in tag_id
  def index
    expose @tag.payloads.map { |p| p.slug }

  rescue Exception => ex
    error! :bad_request, :metadata => {:error_description => ex.message}    
  end
  
  # POST /mobile/:version/payloads
  def create
    payload = @tag.payloads.build(payload_params)
    
    if payload.valid?
      begin
        payload.save!
        
        expose payload.slug
      rescue Exception => ex
        error! :bad_request, :metadata => {:error_description => ex.message} 
      end   
    else
      error! :bad_request, :metadata => {:error_description => payload.errors.full_messages.to_sentence}
    end
  end

  # GET /mobile/:version/payloads/:id
  def show
    set_tag
    
    @payload = @tag.payloads.find(params[:id]) rescue nil
    
    if @payload.nil?
      error! :not_found, :metadata => {:error_description => I18n.t('object_not_found', :obj => 'Payload')}
    else
      result = {:uri => @payload.uri, :text => @payload.content, :threshold => @payload.threshold, 
                :content_type => @payload.content_type,
                :payload_image => @payload.remote_payload_image_url || @payload.mobile_payload_image_url,
                :payload_thumb => @payload.remote_payload_thumb_url || @payload.mobile_payload_thumb_url}  
      expose result
    end
  end
    
  # PUT /mobile/:version/payloads/:id
  def update
    payload = @tag.payloads.find(params[:id]) rescue nil
    
    if payload.nil?
      error! :not_found, :metadata => {:error_description => I18n.t('object_not_found', :obj => 'Payload')}
    else
      begin
        payload.update_attributes!(payload_params)
        head :ok
      rescue Exception => ex
        error! :bad_request, :metadata => {:error_description => ex.message} 
      end   
    end 
  end
  
  # DELETE /mobile/:version/payloads/:id
  def destroy
    payload = @tag.payloads.find(params[:id]) rescue nil
    
    if payload.nil?
      error! :not_found, :metadata => {:error_description => I18n.t('object_not_found', :obj => 'Payload')}
    else
      begin
        payload.destroy
        
        head :ok
      rescue Exception => ex
        error! :bad_request, :metadata => {:error_description => ex.message}   
      end 
    end    
  end
  
private
  def payload_params
    params.require(:payload).permit(:content, :content_type, :threshold, :uri, :payload_image, :remote_payload_image_url, :payload_thumb, :remote_payload_thumb_url, :mobile_payload_image_url, :mobile_payload_thumb_url)
  end
  
  def set_tag
    @tag = NfcTag.find_by_tag_id(params[:tag_id].gsub('-', ''))
        
    error! :not_found, :metadata => {:error_description => I18n.t('object_not_found', :obj => 'NFC Tag')} if @tag.nil?    
  end
  
  def ensure_own_tag
    set_tag

    error! :forbidden, :metadata => {:error_description => I18n.t('invalid_tag_for_payload')}  if @tag.user != current_user
  end
end
