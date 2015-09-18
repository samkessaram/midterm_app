# Homepage (Root path)
get '/' do
  erb :index
end

get '/login' do
  erb :'user/login'
end

get '/oauth/request_token' do
  consumer = OAuth::Consumer.new @@CONSUMER_KEY, @@CONSUMER_SECRET, :site => 'https://api.twitter.com'

  request_token = consumer.get_request_token :oauth_callback => @@CALLBACK_URL
  session[:request_token] = request_token.token
  session[:request_token_secret] = request_token.secret

  puts "request: #{session[:request_token]}, #{session[:request_token_secret]}"

  redirect request_token.authorize_url
end

get '/oauth/callback' do

  consumer = OAuth::Consumer.new @@CONSUMER_KEY, @@CONSUMER_SECRET, :site => 'https://api.twitter.com'

  puts "CALLBACK: request: #{session[:request_token]}, #{session[:request_token_secret]}"

  request_token = OAuth::RequestToken.new consumer, session[:request_token], session[:request_token_secret]
  access_token = request_token.get_access_token :oauth_verifier => params[:oauth_verifier]

  Twitter.configure do |config|
    config.consumer_key = @@CONSUMER_KEY
    config.consumer_secret = @@CONSUMER_SECRET
    config.oauth_token = access_token.token
    config.oauth_token_secret = access_token.secret
  end

  "[#{Twitter.user.screen_name}] access_token: #{access_token.token}, secret: #{access_token.secret}"

  if User.exists?(token:access_token.token)
    @user = User.where(token:access_token.token)[0]
    session[:user_id] = @user.id
    redirect '/tweets'
  else
    @user = User.new(
    token: access_token.token,
    secret: access_token.secret
    )
    if @user.save
      session[:user_id] = @user.id
    else
      redirect '/'
    end
  end
end

get '/tweets' do
  binding.pry
  erb :'tweets/index'
end



post '/tweets/index' do
  if session[:user_id] == nil
    session[:error] = true
    redirect '/'
  end

  format = "%d/%m %H:%M"
  date_time = params[:day] + "/" + params[:month] + " " + params[:hour] + ":" + params[:minute]
  date = DateTime.strptime(date_time, format)
  @tweet = Tweet.create(
    user_id: session[:user_id],
    tweet: params[:tweet],
    post_time: date
    )
  redirect '/tweets'
end

post '/logout' do
  session[:user_id] = nil
  erb :index
end

get '/tweets/all' do
  erb :'tweets/all'
end

post '/tweet/delete' do
  @tweet = Tweet.find(params[:tweet_id])
  @tweet.destroy!
  redirect "/tweets/all"
end


