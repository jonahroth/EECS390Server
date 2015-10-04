#The environment variable DATABASE_URL should be in the following format:
# => postgres://{user}:{password}@{host}:{port}/path
configure :production, :development, :test do
	db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/390server')

	ActiveRecord::Base.establish_connection(
			:adapter => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
			:host     => db.host,
			:username => (ENV['PG_USER'] || db.user),
			:password => (ENV['PG_PASS'] || db.password),
			:database => db.path[1..-1],
			:encoding => 'utf8'
	)
end
