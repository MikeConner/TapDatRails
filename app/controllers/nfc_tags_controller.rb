class NfcTagsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show]
  
  # GET /nfc_tags
  def index
    @tags = current_user.nfc_tags
  end
  
  # GET /nfc_tags/:id
  def show
    @tag = NfcTag.find(params[:id])
  end
  
  # GET /nfc_tags/new
  def new
    @tag = current_user.nfc_tags.build(:tag_id => NfcTag.generate_tag_id)
    @currencies = current_user.currencies.collect {|u| [u.name, u.id] }
  end
  
  # POST /nfc_tags
  def create
    @tag = NfcTag.new(tag_params)
    
    if @tag.save
      redirect_to user_path(current_user, :show_tags => 1), notice: 'NFC Tag was successfully created.'
    else
      @currencies = current_user.currencies.collect {|u| [u.name, u.id] }
      render 'new'
    end
  end
  
  # GET /nfc_tags/:id/edit
  def edit
    @tag = NfcTag.find(params[:id])
    @currencies = current_user.currencies.collect {|u| [u.name, u.id] }
  end
  
  # PUT /nfc_tags/:id
  def update
    @tag = NfcTag.find(params[:id])
    
    if @tag.update_attributes(tag_params)    
      redirect_to user_path(current_user, :show_tags => 1), notice: 'NFC Tag was successfully updated.'
    else
      @currencies = current_user.currencies.collect {|u| [u.name, u.id] }
      render 'new'
    end
  end
  
  # DELETE /nfc_tags/:id
  def destroy
    @tag = NfcTag.find(params[:id])    
    @tag.destroy
    
    redirect_to nfc_tags_path, :notice => 'NFC Tag successfully destroyed'
  end
private
  def tag_params
    params.require(:nfc_tag).permit(:name, :user_id, :currency_id, :tag_id, 
                                    :payloads_attributes => [:id, :uri, :content, :content_type, :threshold, 
                                                             :description, :payload_image, :remote_payload_image_url, 
                                                             :_destroy])    
  end
end
