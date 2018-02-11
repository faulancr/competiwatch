require 'test_helper'

class HeroTest < ActiveSupport::TestCase
  test 'requires name' do
    hero = Hero.new

    refute_predicate hero, :valid?
    assert_includes hero.errors.messages[:name], "can't be blank"
  end

  test 'requires unique name' do
    hero1 = create(:hero)
    hero2 = Hero.new(name: hero1.name)

    refute_predicate hero2, :valid?
    assert_includes hero2.errors.messages[:name], 'has already been taken'
  end

  test 'requires role' do
    hero = Hero.new

    refute_predicate hero, :valid?
    assert_includes hero.errors.messages[:role], "can't be blank"
  end

  test 'requires valid role' do
    hero = Hero.new(role: 'something invalid')

    refute_predicate hero, :valid?
    assert_includes hero.errors.messages[:role], 'is not included in the list'
  end
end
