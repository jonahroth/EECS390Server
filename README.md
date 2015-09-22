# Getting Started

- This server uses Ruby 2.2.1
- Navigate to the folder (390server)
- `gem install bundler`
- `bundle install`
- `ruby app.rb` to launch the server
- To test locally: Make HTTP requests to `127.0.0.1:4567`

# What each path does
[Out of date - see the google doc for current info. To be updated in an upcoming commit.]

**Paths that return HTML**
Path | Function
get `/`  | sign up form
get `/login` | login form
post `/validate` | validates username-password combination
post `/create` | creates and commits username-password combination
get `/about/:id` | displays information about a user
get `/stamps` | displays all stamps with option to purchase stamps
post `/purchase` | purchase a stamp and redirect to `/stamps`

**Paths that return JSON objects**
Path | Function
get `/api/users` | returns a JSON list of users
get `/api/user/:id` | returns information about a specific user
get `/api/stamps` | returns a list of all stamps
get `/api/stamp/:id` | returns information about one specific stamp
get `/api/stamps/user/:id` | returns a list of all stamps owned by a specific user
post `/api/purchase/:userid/:stampid` | attempts to purchase a stamp for a user
post `/api/levelup/:id` | increments user level
get `/api/level/:id` | returns just the level of specified user
post `/api/give/:id/:value` | gives some number of peanuts to a user
get `/api/clear/:id` | removes all stamps from a user
