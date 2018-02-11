require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'requires battletag' do
    user = User.new

    refute_predicate user, :valid?
    assert_includes user.errors.messages[:battletag], "can't be blank"
  end

  test 'requires unique battletag' do
    user1 = create(:user)
    user2 = User.new(battletag: user1.battletag)

    refute_predicate user2, :valid?
    assert_includes user2.errors.messages[:battletag], 'has already been taken'
  end

  test 'deletes OAuth accounts when deleted' do
    user = create(:user)
    oauth_account1 = create(:oauth_account, user: user)
    oauth_account2 = create(:oauth_account, user: user)

    assert_difference 'OauthAccount.count', -2 do
      user.destroy
    end

    refute OauthAccount.exists?(oauth_account1.id)
    refute OauthAccount.exists?(oauth_account2.id)
  end
end
