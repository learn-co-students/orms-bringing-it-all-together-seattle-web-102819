class Dog
    attr_accessor :name, :breed, :id

    def initialize(hash)
       hash.each {|k, v| self.send(("#{k}="), v)}
    end


    ## be sure you save your id back to the object instance
    ## otherwise you'll spend too much time trying to get 
    ## .find_or_create_by to pass ;)
    def save
        if  self.id
            self.update
        else
            sql =<<-SQL 
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
            SQL
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def self.create_table
        sql = "CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)"
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE dogs"
        DB[:conn].execute(sql)
    end

    # def self.new_from_db(array)
    #     dog = Dog.new(id: array[0], name: array[1], breed: array[2])
  
    # end

    def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]
        self.new(id: id, name: name, breed: breed)
    end


    def self.create(hash)
        dog = Dog.new(hash)
        dog.save
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE id = ?
        SQL
        arr = DB[:conn].execute(sql, id)[0]
        Dog.new_from_db(arr)
    end
    
    def self.find_or_create_by(hash)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", hash[:name], hash[:breed])
        if !dog.empty?
            dog_data = dog[0]
            new_dog = Dog.new_from_db(dog_data)
        else
            newer_dog = self.create(hash)
        end
        # binding.pry
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
        dog = DB[:conn].execute(sql, name)[0]
        Dog.new_from_db(dog)
        # binding.pry
    end 

    def update
       sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
       DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end