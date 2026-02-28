require 'sinatra'
require 'json'
require_relative 'my_user_model'
require_relative 'my_project_model' # Add the project model!

set :port, 8080
set :bind, '0.0.0.0'
enable :sessions # This replaces all that manual cookie code

helpers do
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def clean_user(user)
    return nil unless user
    { id: user.id, firstname: user.firstname, lastname: user.lastname, age: user.age, email: user.email }
  end
end

# --- User Routes ---

get '/users' do
  content_type :json
  User.all.map { |u| clean_user(u) }.to_json
end

post '/users' do
  content_type :json
  user = User.create(params)
  status 201
  clean_user(user).to_json
end

post '/sign_in' do
  content_type :json
  user = User.find_by_email(params[:email])
  
  if user && user.password == params[:password]
    session[:user_id] = user.id # Standard Sinatra session
    clean_user(user).to_json
  else
    status 401
    { error: "Invalid credentials" }.to_json
  end
end

delete '/sign_out' do
  session.clear
  status 204
end

# --- Project Routes ---

get '/projects' do
  content_type :json
  Project.all.to_json
end

post '/projects' do
  content_type :json
  if current_user
    # Add the current user's ID as the project owner (Admin)
    project_data = params.merge(user_id: current_user.id)
    project = Project.create(project_data)
    status 201
    project.to_json
  else
    status 401
  end
end

# --- Views ---

get '/' do
  @users = User.all
  @projects = Project.all
  erb :index
end