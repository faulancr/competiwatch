class OverwatchAPIStats
  attr_reader :competitive_heroes, :quickplay_heroes

  def initialize(data, heroes_by_name: {})
    @competitive_heroes = []
    @quickplay_heroes = []

    if stats = data['stats']
      if top_hero_stats = stats['top_heroes']
        if top_hero_stats['competitive']
          @competitive_heroes = top_hero_stats['competitive'].map do |hero_data|
            name = hero_data['hero']
            OverwatchAPIHero.new(hero_data, hero: heroes_by_name[name])
          end
          @competitive_heroes = @competitive_heroes.select(&:any_playtime?).
            sort_by(&:seconds_played).reverse
        end

        if top_hero_stats['quickplay']
          @quickplay_heroes = top_hero_stats['quickplay'].map do |hero_data|
            name = hero_data['hero']
            OverwatchAPIHero.new(hero_data, hero: heroes_by_name[name])
          end
          @quickplay_heroes = @quickplay_heroes.select(&:any_playtime?).
            sort_by(&:seconds_played).reverse
        end
      end
    end
  end

  def top_heroes(limit: 5)
    heroes = if competitive_heroes.any?
      competitive_heroes
    else
      quickplay_heroes
    end
    heroes[0...limit]
  end
end
