require 'sinatra'
# require 'sinatra/reloader' if development?
require 'json'
require_relative 'my_user_model'
require_relative 'my_project_model'
require_relative 'my_attachment_model'
require_relative 'my_thread_model'
require_relative 'my_message_model'

set :port, ENV['PORT'] || 8080
set :bind, '0.0.0.0'
enable :sessions

begin
    # This creates the user you will use to log in
    User.create({
      firstname: "Skeg", 
      lastname: "Admin", 
      age: 25, 
      email: "skeg@test.com", 
      password: "password123"
    })
    puts "SUCCESS: User skeg@test.com created!"
  rescue => e
    # If the user already exists, it just skips this part
    puts "Notice: Seed skipped (User probably already exists)"
  end

helpers do
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def authenticate!
    redirect '/login' unless current_user
  end
end

# --- User & Authentication Routes ---

get '/login' do
  erb :login
end

post '/sign_in' do
  user = User.find_by_email(params[:email])
  
  if user && user.password == params[:password]
    session[:user_id] = user.id
    redirect '/'
  else
    @error = "Invalid credentials"
    erb :login
  end
end

get '/sign_out' do
  session.clear
  redirect '/login'

get '/signup' do
    erb :signup
  end
  
  # Process the Sign Up form
  post '/users' do
    user = User.create({
      firstname: params[:firstname],
      lastname: params[:lastname],
      email: params[:email],
      password: params[:password],
      age: params[:age]
    })
    
    if user
      session[:user_id] = user.id
      redirect '/'
    else
      @error = "Could not create account."
      erb :signup
    end
  end
end

# --- Project Routes (The Views) ---

# DASHBOARD
get '/' do
  authenticate!
  @projects = Project.find_by_user(current_user.id)
  erb :index
end

# PROJECT HUB
get '/projects/:project_id' do
  authenticate!
  @project = Project.find(params[:project_id])
  
  if @project && @project.user_id == current_user.id
    @threads = ThreadModel.find_by_project(params[:project_id])
    @attachments = Attachment.find_by_project(params[:project_id])
    erb :project
  else
    status 403
    "Access Denied: You do not own this project."
  end
end

# THREAD VIEW
get '/projects/:project_id/threads/:thread_id' do
  authenticate!
  @thread = ThreadModel.find(params[:thread_id])
  @messages = Message.find_by_thread(params[:thread_id])
  
  if @thread
    erb :thread
  else
    status 404
    "Thread not found"
  end
end

# --- Action Routes (Form Submissions) ---

# CREATE THREAD
post '/projects/:project_id/threads' do
  authenticate!
  project = Project.find(params[:project_id])
  
  if project && project.user_id == current_user.id
    ThreadModel.create(
      project_id: params[:project_id], 
      title: params[:title], 
      content: params[:content]
    )
    redirect "/projects/#{params[:project_id]}"
  else
    status 403
  end
end

# POST MESSAGE
post '/projects/:project_id/threads/:thread_id/messages' do
  authenticate!
  Message.create(
    thread_id: params[:thread_id], 
    user_id: current_user.id, 
    content: params[:content]
  )
  redirect "/projects/#{params[:project_id]}/threads/#{params[:thread_id]}"
end

# EDIT MESSAGE (Show the form)
get '/projects/:project_id/threads/:thread_id/messages/:id/edit' do
    authenticate!
    @message = Message.find(params[:id])
    # Security: Only the owner can edit
    halt 403, "Not your message!" unless @message.user_id == current_user.id
    erb :edit_message
  end
  
  # UPDATE MESSAGE (Process the change)
  post '/projects/:project_id/threads/:thread_id/messages/:id' do
    authenticate!
    message = Message.find(params[:id])
    if message.user_id == current_user.id
      message.update(content: params[:content]) # Assumes your model has #update
      redirect "/projects/#{params[:project_id]}/threads/#{params[:thread_id]}"
    end
  end
  
  # DELETE MESSAGE
  post '/projects/:project_id/threads/:thread_id/messages/:id/delete' do
    authenticate!
    message = Message.find(params[:id])
    # Allow author OR project owner to delete
    if message.user_id == current_user.id
      Message.destroy(params[:id])
    end
    redirect "/projects/#{params[:project_id]}/threads/#{params[:thread_id]}"
  end

# ATTACHMENTS
post '/projects/:project_id/attachments' do
  authenticate!
  extension = File.extname(params[:filename]).delete('.')
  Attachment.create(
    project_id: params[:project_id], 
    filename: params[:filename], 
    format: extension
  )
  redirect "/projects/#{params[:project_id]}"
end