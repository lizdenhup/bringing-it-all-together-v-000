class Dog 
  attr_accessor :name, :breed
  attr_reader :id 

  def initialize(arguments)
    @name = arguments[:name]
    @breed = arguments[:breed]
    @id = arguments[:id]
  end 

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
      )
      SQL

      DB[:conn].execute(sql)
  end 

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"

    DB[:conn].execute(sql)
  end


  def save
    if self.id
      self.update
    else
    sql = <<-SQL 
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
     SQL
 
     DB[:conn].execute(sql, self.name, self.breed)
     @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
  end

  def self.create(attributes)
    dog = Dog.new(attributes)
    dog.save
    dog
  end 

  def self.find_or_create_by(arguments)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = '#{arguments[:name]}' AND breed = '#{arguments[:breed]}'")
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new_from_db(dog_data)
    else 
      dog = self.create(arguments) 
    end 
    dog 
  end

  def self.new_from_db(row)
    self.new({id: row[0], name: row[1], breed: row[2]})
  end 

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ?
    SQL
    dog = DB[:conn].execute(sql, name)[0]
    Dog.new_from_db(dog)
  end 

def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql, id)[0]
    Dog.new_from_db(result)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end 