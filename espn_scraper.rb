require "mechanize"

# Struct to store team information; team name (string), roster (array), rating (int), id (int), url (string)
Team = Struct.new(:name, :roster, :rating, :id, :url)
Player = Struct.new(:name, :position)

class EspnScraper

  def initialize
    @teams = []
    @urls = []
    @season_id = 2015
    @league_id = 143124
    @num_teams = 12

    @agent = Mechanize.new
    @agent.history_added = Proc.new { sleep 0.5 }
  end

  def create_team_urls
    @num_teams.times do |i|
      @urls << "http://games.espn.go.com/ffl/clubhouse?leagueId=#{@league_id}&teamId=#{i+1}&seasonId=#{@season_id}"
    end
  end

  def create_teams
    @num_teams.times do |i|
      @teams << Team.new(nil, [], nil, i+1, @urls[i])
    end
  end

  def parse_teams
    @teams.each do |team|
      page = @agent.get(team.url)
      team.name = page.search("h3[@class='team-name']").text
      players = page.search("td[@class='playertablePlayerName']")
      players.each do |player|
        hold = player.text.split(",")
        name = hold[0]
        pos = hold[1].gsub(/[[:space:]]/, ' ').split[1]
        team.roster << Player.new(name, pos)
      end
    end
  end

  def urls
    @urls.each do |u|
      p u
    end
  end

  def teams
    @teams.each do |team|
      p team
    end
  end

  def run_scrape
    create_team_urls
    create_teams
    parse_teams
  end

  def print_rosters(id)
    @teams[id-1].roster.each do |player|
      p player.name
      p player.position
      p "-----------------"
    end
  end

end