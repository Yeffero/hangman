

require 'sqlite3'

def database_file
  if !File.exists?("dbfile")

      $db = SQLite3::Database.new("dbfile")
      $db.results_as_hash = true
      create_table

    else
      $db = SQLite3::Database.new("dbfile")
      $db.results_as_hash = true
    end

end


def random_word
  word=""
  if File.exists?("5desk.txt")
    File.open("5desk.txt")
    array_of_lines = File.readlines("5desk.txt")
    #puts "Total de lineas del archivo es #{array_of_lines.length}"
    loop do
        word =array_of_lines.sample
        word.gsub!(/\n/,'')
        #puts "la palabra elegida en el loop es #{word}"
        if word.length >5 && word.length <=12
          break
        end
    end

  else
    puts "ERROR! there is not 5desk.txt file, PLease check it"
    word=""

  end
  #puts "la palabra elegida es #{word} y tinee #{word.length} caracteres "
  idx=-1
  word.each_char {|c| $answer[idx+=1]="_"}
  word
end

def init_answer

  temporal=$secret_word.scan(/\w/)
  #puts "Valor de temporal #{temporal}"
  #puts "Current Answer Status :   #{$answer}"
  temporal.each_with_index { |chr,idx |

        if ($answer[idx]=="_" )
          $answer[idx]="_"
        end
     }
#puts "Current Guess Status :   #{$answer}"

end

def disconnect_and_quit
  $db.close
  puts "Bye!"
  exit
end

def create_table
  puts "Creating game table"
  $db.execute %q{
    CREATE TABLE game (
    id integer primary key,
    name_player varchar(50),
    try integer ,
    secret_word varchar(12),
    answer varchar(12),
    incorrect varchar(50)
  )
  }


end

def add_game
  delete_table
  temporal=$incorrect.join("")
  $db.execute("INSERT INTO game (name_player, try, secret_word,answer,incorrect) VALUES (?, ?, ?,?,?)",
  $name_player, $try-1, $secret_word,$answer,temporal)
end

def search_last_game
  res=$db.execute("select * from game where name_player = ?", $name_player).first
#puts "contenido de res #{res} "
  unless res
    puts "There is not game saved "
    return false
  end

  $try=res['try']
  $secret_word=res['secret_word']
  $answer=res['answer']
  $incorrect=res['incorrect'].scan(/\w/)
  return true
end

def delete_table
  $db.execute("DELETE FROM  game where name_player= ?",$name_player)
end


def play_game

  puts "Lets play,you have #{10-$try} oportunities"


  while $try<10 do
    $try+=1
    puts "Lets play, this is your #{$try} oportunity"
    if check_control
      puts "You Win!!!!"
      $try=11
      delete_table
    end

  end
if $g!="S"
  puts "Sorry You lost . Secret Word is #{$secret_word}"
  delete_table
end
disconnect_and_quit
end

def check_control
  ok=0
  puts "Please type your guess or \"S\" if you like save this game and quit "
  $g=gets.chomp
  if $g=="S"
    add_game
    puts "You Saved  the game ... See you later !!!"
    $try=11
    return false
  end
  $g.downcase!
  $secret_word.downcase!
  temporal=[]

      temporal=$secret_word.scan(/\w/)
      #puts "Valor de temporal #{temporal}"
      #puts "Current Answer Status :   #{$answer}"
      temporal.each_with_index { |chr,idx |
        if chr==$g
            $answer[idx]=chr
            ok=1
        else
            if ($answer[idx]=="_" )
              $answer[idx]="_"

            end
        end   }
        puts "valor de ok #{ok}"
        if ok== 0
          $incorrect << $g
        end
  puts "Current Guess Status :   #{$answer}"
  puts "Current incorrect letters used :  #{$incorrect}"
  string_answer=$answer
   #puts "Current Guess Status string:   #{string_answer}"
  if string_answer == $secret_word
    return true
  else
    return false
  end
end



$try=0
$name_player=""
$secret_word=""
$answer=""
$incorrect=[]
puts "Welcom to Hangman"
$secret_word=random_word
init_answer
#puts "la palabra secreta escogida es #{$secret_word}"

database_file
puts "Please your name : "
$name_player=gets.chomp
$name_player.downcase!
  if search_last_game
    puts "There is a game saved by you , Would you like restore it and continue? (Y/N)"
    res=gets.chomp

    if res.upcase != "Y"
      puts "OK, starting a new game and deleting last game"
      delete_table
      $try=0
      $secret_word=random_word
      $incorrect=[]
      init_answer

    else
      puts "Recover from database following information ... Continuing game "

      puts "Current Guess Status string:   #{$answer}"
      puts "Current incorrect letters used :  #{$incorrect}"
    end


  end

play_game
