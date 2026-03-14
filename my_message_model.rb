require 'sqlite3'

class Message
  attr_accessor :id, :thread_id, :user_id, :content

  def initialize(attributes = {})
    @id        = attributes['id']        || attributes[:id]
    @thread_id = attributes['thread_id'] || attributes[:thread_id]
    @user_id   = attributes['user_id']   || attributes[:user_id]
    @content   = attributes['content']   || attributes[:content]
  end

  def to_h
    {
      id: @id,
      thread_id: @thread_id,
      user_id: @user_id,
      content: @content
    }
  end

  def self.connect
    db = SQLite3::Database.new 'my_basecamp.db'
    db.results_as_hash = true
    db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        thread_id INTEGER,
        user_id INTEGER,
        content TEXT,
        FOREIGN KEY(thread_id) REFERENCES threads(id),
        FOREIGN KEY(user_id) REFERENCES users(id)
      );
    SQL
    db
  end

  def self.create(params)
    db = self.connect
    db.execute("INSERT INTO messages (thread_id, user_id, content) VALUES (?, ?, ?)",
               [params[:thread_id], params[:user_id], params[:content]])
    self.find(db.last_insert_row_id)
  end

  def self.find(id)
    db = self.connect
    row = db.execute("SELECT * FROM messages WHERE id = ?", [id]).first
    return nil unless row
    Message.new(row)
  end

  def self.find_by_thread(thread_id)
    db = self.connect
    rows = db.execute("SELECT * FROM messages WHERE thread_id = ?", [thread_id])
    rows.map { |row| Message.new(row) }
  end
end

def update(params)
    db = Message.connect
    db.execute("UPDATE messages SET content = ? WHERE id = ?", [params[:content], @id])
    @content = params[:content] # Update the object in memory too
    self
  end

  # This is the class method for #destroy
  def self.destroy(id)
    db = self.connect
    db.execute("DELETE FROM messages WHERE id = ?", [id])
  end