require_relative 'my_user_model'
require_relative 'my_project_model'
require_relative 'my_attachment_model'
require_relative 'my_thread_model'
require_relative 'my_message_model'

# 1. Create a User
puts "Creating user..."
user = User.create(firstname: "Alice", lastname: "Smith", email: "alice@test.com", password: "123")
puts "User Created: #{user.firstname} (ID: #{user.id})"

# 2. Create a Project for that User
puts "Creating project..."
project = Project.create(name: "Secret Basecamp", description: "Top secret stuff", user_id: user.id)
puts "Project Created: #{project.name} owned by User ID: #{project.user_id}"

# 3. List all projects
puts "All Projects in DB:"
Project.all.each { |p| puts "- #{p.name}" }

# 4. Create an Attachment for the project
puts "\nTesting Attachments..."
attachment = Attachment.create(project_id: project.id, filename: "blueprint.png", format: "png")
puts "Attachment Created: #{attachment.filename} (Format: #{attachment.format})"

# 5. Create a Thread (Discussion Topic)
puts "\nTesting Threads..."
thread = ThreadModel.create(project_id: project.id, title: "Launch Plan", content: "How do we start?")
puts "Thread Created: #{thread.title} (ID: #{thread.id})"

# 6. Create a Message (Reply in the thread)
puts "\nTesting Messages..."
message = Message.create(thread_id: thread.id, user_id: user.id, content: "I think we should start Monday.")
puts "Message Created: '#{message.content}' by User ID: #{message.user_id}"

# 7. Verify Retrieval
puts "\nVerifying Database Relationships..."
all_threads = ThreadModel.find_by_project(project.id)
all_messages = Message.find_by_thread(thread.id)

puts "Project ID #{project.id} has #{all_threads.length} threads."
puts "Thread ID #{thread.id} has #{all_messages.length} messages."