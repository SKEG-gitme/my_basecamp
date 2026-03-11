# Welcome to My Basecamp 2
***
Use this URL to directly access the rendered project [ https://my-basecamp-5c76.onrender.com]
## For login:
email: "skeg@test.com", 
password: "password123"

## Task
The Problem: The goal was to build a simplified version of "Basecamp," a project management tool. 
It requires managing users, projects, discussion threads, and messages in a structured way.

The Challenge: The main challenge was setting up a Relational Database (SQL) where one user can have many 
projects, and each project can have many threads. Handling the authentication (Login/Session) so users only 
see their own data was a key technical hurdle.

## Description
I used the Sinatra web framework (Ruby) to handle the backend routes.

I followed the MVC (Model-View-Controller) pattern:

Models: Ruby classes that talk to a SQLite3 database using raw SQL queries.

Views: ERB templates for the frontend.

Controller: app.rb to manage logic and sessions.

I implemented a custom authentication system to track the user_id across different pages using browser 
sessions.

## Installation
Clone the repository to your local machine.

Install the necessary Ruby gems:

Bash
bundle install
Ensure you have SQLite3 installed on your system.

Run the server:

Bash
ruby app.rb

## Usage
Start: Run the app and navigate to the provided URL.

Login: Use the provided credentials to enter the dashboard.

Manage: Create a new project from the dashboard.

Collaborate: Inside a project, you can create discussion threads, post messages within those threads, 
and add project attachments.
./my_project argument1 argument2
```

### The Core Team


<span><i>Made at <a href='https://qwasar.io'>Qwasar SV -- Software Engineering School</a></i></span>
<span><img alt='Qwasar SV -- Software Engineering School's Logo' src='https://storage.googleapis.com/qwasar-public/qwasar-logo_50x50.png' width='20px' /></span>
