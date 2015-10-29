=begin
# informs the server about the outcome of a match
# the server will then make the necessary changes in user data
# params[:data] : JSON object of the form
{
  "datetime":<match date/time in standard format>,
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
    } // etc.
  ]
}
=end

# the rationale for using this format is that the game may
# eventually expand to more than two-player games with the
# potential for multiple winners per round (in coop mode)
post '/api/match/results' do
  data = JSON.parse params[:data]

  this_match = Match.create(:datetime => DateTime.parse(data[:datetime]))

  participants = []

  data[:players].each do |d|
    user = User.find_by(:id => d.id)
    user.peanuts += d.peanuts
    if d.winner
      user.level += score
    else
      user.level = (user.level - score >= 0 ? user.level - score : 0)
    end

    participants.append MatchParticipant.create(
      :user_id => user.id,
      :match_id => this_match.id,
      :winner => (d.winner == "true"),
      :score => d.score.to_i
    )

  end

  return_data = {:match => this_match, :participants => participants}

  content_type :json
  return_data.to_json

end

# level starts at 1 and goes up
# rank starts at 1000
=begin
users have experience (peanuts) to keep track of
rank increases or decreases based on peanuts - don't worry about it for now
=end
