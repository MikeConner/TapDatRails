class CurrenciesController < ApplicationController
  respond_to :html, :js
  
  before_filter :authenticate_user!
  before_filter :ensure_admin_user, :except => [:index, :show, :report]
  before_filter :ensure_own_currency_or_admin, :only => [:report]
  
  # GET /currencies
  def index
    @currencies = current_user.admin? ? Currency.all : current_user.currencies
  end

  # GET /currencies/1
  def show
    @currency = Currency.find(params[:id])
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
    @currency = Currency.find(params[:id])
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
    @currency = Currency.find(params[:id])
    
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
    @currency = Currency.find(params[:id])
    @currency.destroy

    redirect_to currencies_path
  end

  # GET /currencies/:id/report
  def report
    tx = []
    @currency.nfc_tags.where(:currency_id => @currency.id).select { |tag| tx.concat(tag.transactions.to_a) }
    
    @transactions = Transaction.where("id in (?)", tx)
    @image_map = Hash.new
    @names_map = Hash.new
    @tag_map = Hash.new
    @voucher_map = Hash.new
    
    @transactions.map { |t| @image_map[t.user_id] = t.user.profile_image_url(:thumb).to_s || t.user.mobile_profile_thumb_url } 
    @transactions.map { |t| @image_map[t.dest_id] = User.find_by_id(t.dest_id).profile_image_url(:thumb).to_s || User.find_by_id(t.dest_id).mobile_profile_thumb_url } 
    @transactions.map { |t| @names_map[t.user_id] = User.find_by_id(t.user_id).name } 
    @transactions.map { |t| @names_map[t.dest_id] = User.find_by_id(t.dest_id).name } 
    
    @transactions.map { |t| @tag_map[t.nfc_tag_id] = NfcTag.find(t.nfc_tag_id).legible_id unless t.nfc_tag_id.nil? }
    @transactions.map { |t| @voucher_map[t.voucher_id] = Voucher.find(t.voucher_id).uid unless t.voucher_id.nil? }
  end
  
  # GET /currencies/:id/leader_board
  def leader_board
    @currency = Currency.find(params[:id])
    transactions = @currency.transaction_ids
    
    @tappers = Transaction.where('id in (?)', transactions).select("user_id, sum(amount) as total, count(user_id) as taps").group('user_id').order('total DESC')
    @tapped = Transaction.where('id in (?)', transactions).select("nfc_tag_id, sum(amount) as total, count(user_id) as taps").group('nfc_tag_id').order('total DESC')
    @image_map = Hash.new
    @names_map = Hash.new
    
    @tappers.map { |t| @image_map[t.user_id] = t.user.mobile_profile_thumb_url || t.user.profile_image_url(:thumb).to_s } 
    @tappers.map { |t| @names_map[t.user_id] = User.find_by_id(t.user_id).name } 
    @tapped.map { |t| @names_map[t.nfc_tag_id] = NfcTag.find_by_id(t.nfc_tag_id).name unless t.nfc_tag_id.nil? } 

    @last_tx = Transaction.where('nfc_tag_id IS NOT NULL').order('created_at DESC').first

    respond_to do |format|
      format.html
      format.json { render :json => [@tappers, @tapped] }
    end
  end

  # Leader board that doesn't refresh the screen
  # GET /currencies/:id/fast_leader_board
  def fast_leader_board
    @currency = Currency.find(params[:id])
    transactions = @currency.transaction_ids
    
    @tappers = Transaction.where('id in (?)', transactions).select("user_id, sum(amount) as total, count(user_id) as taps").group('user_id').order('total DESC').limit(5)
    @tapped = Transaction.where('id in (?)', transactions).select("nfc_tag_id, sum(amount) as total, count(user_id) as taps").group('nfc_tag_id').order('total DESC').limit(5)
    @image_map = Hash.new
    @names_map = Hash.new
    
    @tappers.map { |t| @image_map[t.user_id] = t.user.mobile_profile_thumb_url || t.user.profile_image_url(:thumb).to_s } 
    @tappers.map { |t| @names_map[t.user_id] = User.find_by_id(t.user_id).name } 
    @tapped.map { |t| @names_map[t.nfc_tag_id] = NfcTag.find_by_id(t.nfc_tag_id).name unless t.nfc_tag_id.nil? } 

    @last_tx = Transaction.where('nfc_tag_id IS NOT NULL').order('created_at DESC').first

    respond_to do |format|
      format.html 
      format.json { render :json => [@tappers, @tapped] }
    end
  end
  
  # PUT /currencies/:id/update_poll
  def update_poll
    puts params
    
    respond_to do |format|
      format.html
      format.js { head :ok }
    end
  end
  
  # GET /currencies/:id/clear_tx
  def clear_tx
    @currency = Currency.find(params[:id])
    
    ids = Transaction.where('nfc_tag_id IS NOT NULL').joins(:nfc_tag).select { |t| t.nfc_tag.currency_id == @currency.id }.map(&:id)
    unless ids.empty?
      puts "Deleting #{ids.count} transactions"
      Transaction.where('id in (?)', ids).destroy_all
    end
    
    redirect_to currencies_path, :notice => 'Data Cleared'
  end

private
  def ensure_own_currency_or_admin
    @currency = Currency.find(params[:id])
    
    unless current_user.admin? or (@currency.user == current_user)
      redirect_to currencies_path, :alert => I18n.t('not_currency_owner')
    end
  end
  
  def currency_params
    params.require(:currency).permit(:expiration_days, :icon, :symbol, :remote_icon_url, :name, :status, :max_amount, :reserve_balance, :user_id, 
                                     :denominations_attributes => [:id, :value, :image, :remote_image_url, :caption, :_destroy],
                                     :single_code_generators_attributes => [:id, :value, :code, :start_date, :end_date, :_destroy])
  end
end
