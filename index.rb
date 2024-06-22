#!C:\Ruby32-x64\bin\ruby.exe

require 'mysql2'
require 'cgi'

begin
  client = Mysql2::Client.new(
    host: 'localhost',
    username: 'root',
    password: '1234567890',
    database: 'telescope_db',
    encoding: 'utf8'
  )
rescue Mysql2::Error => e
  puts "Content-type: text/html\n\n"
  puts "<html><body>"
  puts "<h1>Error connecting to MySQL: #{e.message}</h1>"
  puts "</body></html>"
  exit 1
end

puts "Content-type: text/html\n\n"
puts "<html><body>"

cgi = CGI.new

# Получение значений из формы
type = cgi['type']
accuracy = cgi['accuracy']
quantity = cgi['quantity']
time = cgi['time']
date = cgi['date']
notes = cgi['notes']
sector_id = cgi['sector_id']
delete_id = cgi['delete_id']

# Проверка заполненности обязательных полей для добавления
if type != '' && accuracy != '' && quantity != '' && time != '' && date != ''
  begin
    statement = client.prepare("INSERT INTO Objects (type, accuracy, quantity, time, date, notes, sector_id) VALUES (?, ?, ?, ?, ?, ?, ?)")
    statement.execute(type, accuracy, quantity, time, date, notes, sector_id)
    statement.close
  rescue Mysql2::Error => e
    puts "<p>Error inserting data: #{e.message}</p>"
  end
end

# Удаление строки по id
if delete_id != ''
  begin
    delete_statement = client.prepare("DELETE FROM Objects WHERE object_id = ?")
    delete_statement.execute(delete_id)
    delete_statement.close
  rescue Mysql2::Error => e
    puts "<p>Error deleting data: #{e.message}</p>"
  end
end

def callJoinTables(client, table1, table2)
  begin
    query = "CALL JoinTables(?, ?)"
    statement = client.prepare(query)
    result = statement.execute(table1, table2)
    
    puts '<table><tr>'
    result.fields.each do |field|
      puts "<th>#{field}</th>"
    end
    puts '</tr>'
    
    result.each do |row|
      puts "<tr>"
      row.each do |key, value|
        puts "<td>#{value}</td>"
      end
      puts "</tr>"
    end
    puts '</table>'
    statement.close
  rescue Mysql2::Error => e
    puts "<p>Error executing procedure: #{e.message}</p>"
  end
end

# Главная функция для показа строк, работает всегда
def viewSelect(client)
  begin
    results = client.query("SELECT * FROM Sectors")
    puts '<table><tr>'
    results.fields.each do |field|
      puts "<th>#{field}</th>"
    end
    puts '</tr>'

    results.each do |row|
      puts "<tr>"
      row.each do |key, value|
        puts "<td>#{value}</td>"
      end
      puts "</tr>"
    end
    puts '</table>'
  rescue Mysql2::Error => e
    puts "<p>Error fetching data: #{e.message}</p>"
  end
end

# Подпись
def viewVer(client)
  begin
    results = client.query("SELECT VERSION() AS ver")
    results.each do |row|
      puts "<p>MySQL Version: #{row['ver']}</p>"
    end
    results.free
  rescue Mysql2::Error => e
    puts "<p>Error fetching version: #{e.message}</p>"
  end
end

# Чтение шаблона и отображение на экране
File.readlines('C:/Users/gdhjdg/Downloads/skola/ИТМО/2-семестр/Базы_данных_и_знаний/Модуль3/practRuby/select.html').each do |line|
  if line.strip == "@tr"
    viewSelect(client)
  elsif line.strip == "@ver"
    viewVer(client)
  else
    puts line
  end
end

puts "</body></html>"
