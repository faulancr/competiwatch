class Admin::AccountsController < ApplicationController
  before_action :require_admin

  def index
    @accounts = Account.order_by_battletag.paginate(page: current_page, per_page: 20)
    @userless_accounts = Account.without_user.order_by_battletag
    @user_options = [['--', '']] + User.order_by_battletag.map { |user| [user.battletag, user.id] }
    @userless_account_options = [['--', '']] +
      @userless_accounts.map { |account| [account.battletag, account.id] }
    @deletable_accounts = Account.without_matches.sole_accounts.not_recently_updated
  end

  def prune
    PruneOldAccountsJob.perform_later
    redirect_to admin_accounts_path, notice: 'Deleting old sole accounts without matches...'
  end

  def update
    unless params[:user_id] && params[:account_id]
      flash[:error] = 'Please specify a user and an account.'
      return redirect_to(admin_path)
    end

    user = User.find(params[:user_id])
    account = Account.find(params[:account_id])
    account.user = user

    if account.save
      flash[:notice] = "Successfully tied account #{account} to user #{user}."
    else
      flash[:error] = "Could not tie account #{account} to user #{user}: " +
                      account.errors.full_messages.join(', ')
    end

    redirect_to admin_path
  end
end
