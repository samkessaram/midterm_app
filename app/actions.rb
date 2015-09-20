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
    session[:error] = nil
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
  erb :'tweets/index'
end


post '/tweets' do
  if session[:user_id] == nil
    session[:error] = true
    redirect '/'
  end

  @tweet = Tweet.new(
    user_id: session[:user_id],
    tweet: params[:tweet],
    post_time: Chronic.parse(params[:timeof])
    )
  if @tweet.save
    session[:error] = false
    session[:post_time] = @tweet.post_time
    redirect '/tweets'
  else
    erb  :'/tweets/index'
  end
end

post '/logout' do
  session[:user_id] = nil
  erb :index
end

get '/tweets/all' do
  erb :'tweets/all'
end

post '/tweets/all' do
Tweet.find(params[:tweet_id]).destroy!
  erb :'tweets/all'
end

get '/timeline' do
  @user = User.find(session[:user_id])
    client = Twitter.configure do |config|
      config.consumer_key = @@CONSUMER_KEY
      config.consumer_secret = @@CONSUMER_SECRET
      config.oauth_token = @user.token
      config.oauth_token_secret = @user.secret
    end

  @timeline = client.user_timeline(options = {count:10})

  erb :'tweets/timeline'

end



