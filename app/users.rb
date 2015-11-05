# creates a new user based on username and password params
# (password confirmation is assumed client side)
post '/api/users/create' do

  @user = make_user params[:username], params[:password], nil
  content_type :json
  @user.to_json

end

# creates a user linked with a facebook account
# params: name = [real name from facebook], id = [unique identifier from facebook]
post '/api/users/create/fb' do
  facebook = {:name => params[:name], :id => params[:id]}
  username = params[:name].gsub(/[^A-Za-z]/).downcase
  password = id + " " + username
  @user = make_user username, password, facebook
end
