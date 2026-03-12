require 'sqlite3'

class User
  attr_accessor :id, :firstname, :lastname, :age, :email, :password

  def initialize(attributes = {})
    @id = attributes['id']
    @firstname = attributes['firstname']
    @lastname = attributes['lastname']
    @age = attributes['age']
    @email = attributes['email']
    @password = attributes['password']
    @is_admin = attributes['is_admin'] || 0
  end

  def self.connect
    db = SQLite3::Database.new 'my_basecamp.db'
    db.results_as_hash = true
  
    
    # This MUST run every time to ensure table exists
    db.execute <<-SQL
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      firstname TEXT, lastname TEXT, age INTEGER, email TEXT, password TEXT,
      is_admin INTEGER DEFAULT 0  -- 0 is normal user, 1 is admin
    );
  SQL
  db
end

  def self.create(params)
    db = self.connect
    db.execute(
      "INSERT INTO users (firstname, lastname, age, email, password) VALUES (?, ?, ?, ?, ?)",
      [params[:firstname], params[:lastname], params[:age], params[:email], params[:password]]
    )
    id = db.last_insert_row_id
    self.find(id)
  end

  def self.find(user_id)
    db = self.connect
    row = db.execute("SELECT * FROM users WHERE id = ?", user_id).first
    row ? User.new(row) : nil
  end

  def self.find_by_email(email)
    db = self.connect
    row = db.execute("SELECT * FROM users WHERE email = ?", [email]).first
    row ? User.new(row) : nil
  end

  def self.all
    db = self.connect
    rows = db.execute("SELECT * FROM users")
    rows.map { |row| User.new(row) }
  end

  def self.update(user_id, field, value)
    db = self.connect
    db.execute("UPDATE users SET #{field} = ? WHERE id = ?", [value, user_id])
    self.find(user_id)
  end

  def self.set_admin(user_id)
    self.update(user_id, 'is_admin', 1)
  end

  def self.destroy(user_id)
    db = self.connect
    db.execute("DELETE FROM users WHERE id = ?", user_id)
  end

  def to_h
    {
      'id' => @id,
      'firstname' => @firstname,
      'lastname' => @lastname,
      'age' => @age,
      'email' => @email,
      'password' => @password
    }
  end
end