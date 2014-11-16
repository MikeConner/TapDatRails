class CurrenciesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :currency_owner, :except => [:index, :new, :create]
  
  # GET /currencies
  def index
    @currencies = current_user.currencies
  end

  # GET /currencies/1
  def show
  end

  # GET /currencies/new
  def new
    @currency = current_user.currencies.build    
  end

  # GET /currencies/1/edit
  def edit
  end

  # POST /currencies
  def create
    @currency = current_user.currencies.new(params[:currency])

    @currency.encode_denominations
        
    if @currency.save
      redirect_to @currency, notice: 'Currency was successfully created.'
    else
      render 'new'
    end
  end

  # PUT /currencies/1
  def update
    @currency.encode_denominations
    
    params[:currency][:denominations] = @currency.denominations

    if @currency.update_attributes(params[:currency])
      redirect_to @currency, notice: 'Currency was successfully updated.'
    else
      render 'edit'
    end
  end

  # DELETE /currencies/1
  def destroy
    @currency.destroy

    redirect_to currencies_path
  end

private
  def currency_owner
    @currency = Currency.find(params[:id])
    if @currency.user != current_user
      redirect_to root_path, I18n.t('not_currency_owner')
    end
  end  
end
