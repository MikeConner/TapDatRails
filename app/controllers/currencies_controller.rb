class CurrenciesController < ApplicationController
  respond_to :html, :js
  
  before_filter :authenticate_user!
  before_filter :ensure_admin_user, :except => [:index, :show]
  
  # GET /currencies
  def index
    @currencies = current_user.admin? ? Currency.all : current_user.currencies
  end

  # GET /currencies/1
  def show
    @currency = Currency.friendly.find(params[:id])
  end

  # GET /currencies/new
  def new
    @currency = current_user.currencies.build    
    @issuers = User.all.collect {|u| [u.name, u.id] }
    if @issuers.empty?
      redirect_to currencies_path, :notice => 'No currency issuers available'
    end
  end

  # GET /currencies/1/edit
  def edit
    @currency = Currency.friendly.find(params[:id])
    @issuers = User.all.collect {|u| [u.name, u.id] }
    if @issuers.empty?
      redirect_to currencies_path, :notice => 'No currency issuers available'
    end
  end

  # POST /currencies
  def create
    user = User.find(params[:currency][:user_id])
    @currency = user.currencies.new(currency_params)
        
    if @currency.save
      unless 0 == @currency.reserve_balance
        ActiveRecord::Base.transaction do
          tx = @currency.user.transactions.create!(:dest_id => current_user.id,
                                                   :comment => "Initial funding",
                                                   :amount => @currency.reserve_balance)  
          rate = @currency.conversion_rate
          
          tx.transaction_details.create!(:subject_id => 0, :target_id => user.id, :credit => @currency.reserve_balance, :conversion_rate => rate)      
          tx.transaction_details.create!(:subject_id => 0, :target_id => current_user.id, :debit => @currency.reserve_balance, :conversion_rate => rate)      
        end
      end
      
      redirect_to @currency, notice: 'Currency was successfully created.'
    else
      @issuers = User.all.collect {|u| [u.name, u.id] }
      render 'new'
    end
  end

  # PUT /currencies/1
  def update
    @currency = Currency.friendly.find(params[:id])
    
    funding_transaction = Hash.new
    
    # Assign instead of updating so that we can see what changed. (Updating, if successful, will reset changed flags)
    # Note that Assign does not return anything, so we can't test its value. (It will throw an exception for unpermitted params.)
    @currency.assign_attributes(currency_params)
    if @currency.reserve_balance_changed?
      funding_transaction[:old] = @currency.reserve_balance_was
      funding_transaction[:new] = @currency.reserve_balance      
      funding_transaction[:comment] = "Reserve balance of #{@currency.name} changed from #{@currency.reserve_balance_was} to #{@currency.reserve_balance}"
      
      Rails.logger.info funding_transaction[:comment]
    end
      
    if @currency.save
      unless funding_transaction.empty?
        ActiveRecord::Base.transaction do
          adjustment = funding_transaction[:new] - funding_transaction[:old]
          
          tx = @currency.user.transactions.create!(:dest_id => current_user.id, # funding is from us
                                                   :comment => funding_transaction[:comment],
                                                   :amount => [0, adjustment].max)  
          rate = @currency.conversion_rate
          
          if adjustment <= 0
            tx.transaction_details.create!(:subject_id => 0, :target_id => current_user.id, :credit => adjustment.abs, :conversion_rate => rate)      
            tx.transaction_details.create!(:subject_id => 0, :target_id => @currency.user.id, :debit => adjustment.abs, :conversion_rate => rate)      
          else 
            tx.transaction_details.create!(:subject_id => 0, :target_id => @currency.user.id, :credit => adjustment, :conversion_rate => rate)      
            tx.transaction_details.create!(:subject_id => 0, :target_id => current_user.id, :debit => adjustment, :conversion_rate => rate)      
          end
        end
      end
      
      redirect_to @currency, notice: 'Currency was successfully updated.'
    else
      @issuers = User.all.collect {|u| [u.name, u.id] }
      render 'edit'
    end
  end

  # DELETE /currencies/1
  def destroy
    @currency = Currency.friendly.find(params[:id])
    @currency.destroy

    redirect_to currencies_path
  end

  # GET /currencies/:id/leader_board
  def leader_board
    @currency = Currency.friendly.find(params[:id])

    transactions = []
    @currency.nfc_tags.where(:currency_id => @currency.id).select { |tag| transactions.concat(tag.transactions.to_a) }
    
    @tappers = Transaction.where("id in (?)", transactions).select("user_id, sum(amount) as total, count(user_id) as taps").group('user_id').order('total DESC')
    @tapped = Transaction.where("id in (?)", transactions).select("dest_id, sum(amount) as total, count(user_id) as taps").group('dest_id').order('total DESC')
    @image_map = Hash.new
    @names_map = Hash.new
    
    @tappers.map { |t| @image_map[t.user_id] = t.user.profile_thumb.url || t.user.mobile_profile_thumb_url } 
    @tapped.map { |t| @image_map[t.dest_id] = User.find_by_id(t.dest_id).profile_thumb.url || User.find_by_id(t.dest_id).mobile_profile_thumb_url } 
    @tappers.map { |t| @names_map[t.user_id] = User.find_by_id(t.user_id).name } 
    @tapped.map { |t| @names_map[t.dest_id] = User.find_by_id(t.dest_id).name } 

    respond_to do |format|
      format.html
      format.json { render :json => [@tappers, @tapped] }
    end
  end
  
private
  def currency_params
    params.require(:currency).permit(:expiration_days, :icon, :symbol, :remote_icon_url, :name, :status, :max_amount, :reserve_balance, :user_id, 
                                     :denominations_attributes => [:id, :value, :image, :remote_image_url, :caption, :_destroy],
                                     :single_code_generators_attributes => [:id, :value, :code, :start_date, :end_date, :_destroy])
  end
end
