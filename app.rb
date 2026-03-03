require 'sinatra'
require 'json'
require_relative 'my_user_model'
require_relative 'my_project_model'
require_relative 'my_attachment_model'
require_relative 'my_thread_model'
require_relative 'my_message_model'

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
    project_data = params.merge(user_id: current_user.id)
    project = Project.create(project_data)
    status 201
    project.to_json
  else
    status 401
  end
end

# ATTACHMENTS
post '/projects/:project_id/attachments' do
    content_type :json
    return status 401 unless current_user
    extension = File.extname(params[:filename]).delete('.')
    attachment = Attachment.create(project_id: params[:project_id], filename: params[:filename], format: extension)
    status 201
    attachment.to_h.to_json
  end
  
  # THREADS
  post '/projects/:project_id/threads' do
    content_type :json
    return status 401 unless current_user
    project = Project.find(params[:project_id])
    if project && project.user_id == current_user.id
      thread = ThreadModel.create(project_id: params[:project_id], title: params[:title], content: params[:content])
      status 201
      thread.to_h.to_json
    else
      status 403
      { error: "Access Denied: You are not the owner of this project." }.to_json
    end
  end
  
  get '/projects/:project_id/threads' do
    content_type :json
    threads = ThreadModel.find_by_project(params[:project_id])
    threads.map(&:to_h).to_json
  end
  
  # MESSAGES
  post '/projects/:project_id/threads/:thread_id/messages' do
    content_type :json
    return status 401 unless current_user
    message = Message.create(thread_id: params[:thread_id], user_id: current_user.id, content: params[:content])
    status 201
    message.to_h.to_json
  end
  
  get '/projects/:project_id/threads/:thread_id' do
    content_type :json
    thread = ThreadModel.find(params[:thread_id])
    messages = Message.find_by_thread(params[:thread_id])
    if thread
      { thread: thread.to_h, replies: messages.map(&:to_h) }.to_json
    else
      status 404
      { error: "Thread not found" }.to_json
    end
  end
# --- Views ---

get '/' do
  @users = User.all
  @projects = Project.all
  erb :index
end