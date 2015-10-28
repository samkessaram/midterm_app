# Homepage (Root path)
get '/' do
  erb :index
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

  client = Twitter.configure do |config|
    config.consumer_key = @@CONSUMER_KEY
    config.consumer_secret = @@CONSUMER_SECRET
    config.oauth_token = access_token.token
    config.oauth_token_secret = access_token.secret
  end

  session[:avatar] = client.user.profile_image_url.gsub 'normal','bigger'
  session[:handle] = "@#{client.user.handle}"

  if User.exists?(token:access_token.token)
    @user = User.find_by(token:access_token.token)
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
  if session[:user_id] == nil
    session[:error] = true
    redirect '/'
  end
end


post '/tweets' do
  if session[:user_id] == nil
    session[:error] = true
    redirect '/'
  end

  post_time = Chronic.parse(params[:timeof])

  if post_time.min % 10 != 0
    post_time = (post_time - (post_time.min * 60)) + ( post_time.min - (post_time.min % 10) + 10 ) * 60
  else
    post_time
  end

  @tweet = Tweet.new(
    user_id: session[:user_id],
    tweet: params[:tweet],
    post_time: post_time
    )

  if @tweet.save
    session[:error] = false
    session[:post_time] = @tweet.post_time
    redirect '/tweets'
  else
    erb :'tweets/index'
  end
end

post '/logout' do
  session[:user_id] = nil
  session[:avatar] = "http://pbs.twimg.com/profile_images/2284174872/7df3h38zabcvjylnyfe3_bigger.png"
  session[:handle] = " "
  erb :index
end

get '/tweets/all' do
  if session[:user_id] == nil
    session[:error] = true
    redirect '/'
  end

  erb :'tweets/all'
end

post '/tweets/all' do
Tweet.find(params[:tweet_id]).destroy!
  erb :'tweets/all'
end

get '/timeline' do

  if session[:user_id] == nil
    session[:error] = true
    redirect '/'
  else
    @user = User.find(session[:user_id])
      client = Twitter.configure do |config|
        config.consumer_key = @@CONSUMER_KEY
        config.consumer_secret = @@CONSUMER_SECRET
        config.oauth_token = @user.token
        config.oauth_token_secret = @user.secret
      end

    @timeline = client.user_timeline(options = {count:5})

    erb :'tweets/timeline'
  end

end

get '/analytics' do
  if session[:user_id] == nil
    session[:error] = true
    redirect '/'
  end
  
  @user = User.find(session[:user_id])
   client = Twitter.configure do |config|
      config.consumer_key = @@CONSUMER_KEY
      config.consumer_secret = @@CONSUMER_SECRET
      config.oauth_token = @user.token
      config.oauth_token_secret = @user.secret
    end
    @tweet_words = client.user_timeline(options = {count:20})
    tweet_arry = []
    @tweet_words.each do |obj|
      tweet_arry << obj.text
    end
    joined_tweets = tweet_arry.join(' ')
    split_tweets = joined_tweets.split
    @word_count = Hash.new(0)

    split_tweets.each do |word|
      @word_count[word] += 1
    end
    @word_count = @word_count.sort_by {|k,v| v}.reverse
    erb :'user/analytics'
end




