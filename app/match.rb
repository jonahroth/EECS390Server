=begin
# informs the server about the outcome of a match
# the server will then make the necessary changes in user data
# params[:data] : JSON object of the form
{
  "datetime": <match date/time in standard format>,
  "level": <x where xbox is the name of the level, e.g. "birch" or "beach">,
  "players": [
    {
      "id": <userid>,
      "score": <score>,
      "peanuts": <peanuts>,
      "winner": <true/false>
    },
    {
      "id": <userid>,
      "score": <score>,
      "peanuts": <peanuts>,
      "winner": <true/false>
    },... // etc.
  ]
}
=end

# the rationale for using this format is that the game may
# eventually expand to more than two-player games with the
# potential for multiple winners per round (in coop mode)
post '/api/match' do

  # level starts at 1 and goes up
  # rank starts at 1000
=begin
users have experience (peanuts) to keep track of
rank increases or decreases based on peanuts - don't worry about it for now
=end

  validate params
  data = JSON.parse params[:data]

  this_match = Match.create(:match_datetime => DateTime.parse(data["datetime"]), :level => data["level"] || "birch")

  participants = []

  data["players"].each do |d|
    user = User.find_by(:id => d["id"].to_i)
    user.peanuts += d["peanuts"].to_i
    if d["winner"] == "true"
      user.level += d["score"].to_i
    else
      user.level = (user.level - d["score"].to_i >= 0 ? user.level - d["score"].to_i : 0)
    end

    participants.append MatchParticipant.create(
      :user_id => user.id,
      :match_id => this_match.id,
      :winner => (d["winner"] == "true"),
      :score => d["score"].to_i
    )

  end

  return_data = {:match => this_match, :participants => participants}

  content_type :json
  return_data.to_json

end

# returns all matches
get '/api/match' do
  content_type :json
  Match.all.to_json
end

# returns the specified match
get '/api/match/:id' do
  index = params[:id].to_i
  match = Match.find_by(:id => index)

  content_type :json
  match.to_json
end

# returns all matches with a given user as a participant
get '/api/match/user/:id' do
  matches = MatchParticipant.where(:user_id => params[:id].to_i).map {|mp| Match.find_by(:id => mp.match_id)}.uniq

  data = JSON.parse(matches.to_json)
  # eh, it's hacky but it'll do

  data.each do |d|
    d["participants"] = MatchParticipant.where(:match_id => d["id"].to_i)
  end

  content_type :json
  data.to_json
end
