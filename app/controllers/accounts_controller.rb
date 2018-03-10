class AccountsController < ApplicationController
  before_action :authenticate_user!, except: [:avatar, :show]
  before_action :set_account, only: [:destroy, :set_default, :show, :update, :avatar]
  before_action :ensure_account_is_mine, only: [:destroy, :set_default, :update]

  def index
    @accounts = current_user.accounts.includes(:user).order_by_battletag
  end

  def avatar
    unless @account.avatar_url.present?
      SetProfileDataJob.perform_now(@account.id)
      @account.reload
    end
    @include_link = params[:include_link] == '1'
    render partial: 'accounts/avatar', layout: false
  end

  def show
    heroes_by_name = Hero.order_by_name.map { |hero| [hero.name, hero] }.to_h
    @stats = @account.overwatch_api_stats(heroes_by_name)
    @is_owner = signed_in? && @account.user == current_user

    @match_count_by_season = Hash.new(0)
    matches = @account.matches.select(:season).order(season: :desc)
    matches = matches.publicly_shared unless @is_owner
    matches.each do |match|
      @match_count_by_season[match.season] += 1
    end

    @season_shares_by_season = @account.season_shares.group_by(&:season)
  end

  def set_default
    current_user.default_account = @account

    if current_user.save
      flash[:notice] = "Your default account is now #{@account}."
    else
      flash[:error] = 'Could not update your default account at this time.'
    end

    redirect_to accounts_path
  end

  def update
    @account.assign_attributes account_params

    if @account.save
      flash[:notice] = "Successfully updated #{@account}."
    else
      flash[:error] = "Could not update #{@account}: " +
                      @account.errors.full_messages.join(', ')
    end

    redirect_to accounts_path
  end

  def destroy
    unless @account.can_be_unlinked?
      flash[:error] = "#{@account} cannot be unlinked from your account."
      return redirect_to(accounts_path)
    end

    @account.user = nil
    if @account.save
      flash[:notice] = "Successfully disconnected #{@account}."
    else
      flash[:error] = "Could not disconnect #{@account}."
    end
    redirect_to accounts_path
  end

  private

  def account_params
    params.require(:account).permit(:platform, :region)
  end
end
