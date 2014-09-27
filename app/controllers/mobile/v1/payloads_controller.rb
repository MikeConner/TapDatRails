class Mobile::V1::PayloadsController < ApiController
  before_filter :after_token_authentication
  before_filter :ensure_own_tag
  
  # GET /mobile/:version/payloads
  # Must pass in tag_id
  def index
    expose @tag.payloads.map { |p| p.id }

  rescue Exception => ex
    error! :bad_request, :metadata => {:error_description => ex.message}    
  end
  
  # POST /mobile/:version/payloads
  def create
    payload = @tag.payloads.build(params[:payload])
    
    if payload.valid?
      begin
        payload.save!
        
        expose payload.id
      rescue Exception => ex
        puts ex.message
        error! :bad_request, :metadata => {:error_description => ex.message} 
      end   
    else
      error! :bad_request, :metadata => {:error_description => payload.errors.full_messages.to_sentence}
    end
  end

  # GET /mobile/:version/payloads/:id
  def show
    @payload = @tag.payloads.find_by_id(params[:id])
    
    if @payload.nil?
      error! :not_found, :metadata => {:error_description => I18n.t('object_not_found', :obj => 'Payload')}
    else
      result = {:uri => @payload.uri, :text => @payload.content, :threshold => @payload.threshold}  
      expose result
    end
  end
    
  # PUT /mobile/:version/payloads/:id
  def update
    payload = @tag.payloads.find_by_id(params[:id])
    
    if payload.nil?
      error! :not_found, :metadata => {:error_description => I18n.t('object_not_found', :obj => 'Payload')}
    else
      begin
        payload.update_attributes!(params[:payload])
        head :ok
      rescue Exception => ex
        error! :bad_request, :metadata => {:error_description => ex.message} 
      end   
    end 
  end
  
  # DELETE /mobile/:version/payloads/:id
  def destroy
    payload = @tag.payloads.find_by_id(params[:id])
    
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
  def ensure_own_tag
    @tag = NfcTag.find_by_tag_id(params[:tag_id])
    
    if @tag.nil?
      error! :not_found, :metadata => {:error_description => I18n.t('object_not_found', :obj => 'NFC Tag')}
    elsif @tag.user != current_user
      error! :forbidden, :metadata => {:error_description => I18n.t('invalid_tag_for_payload')}
    end
  end
end
