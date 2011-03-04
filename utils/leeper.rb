#!/usr/bin/ruby -w

file = File.new("naceayuda.txt", "r")
fo = File.new("naceayuda.sql", "w")

ant=""
buffer=""
entra = 1

while (line = file.gets)
  # puts "#{line}"


  if ( line =~ /^\d/ )
   ff = line.split(' ')
   # puts "empieza con un numero #{ff[0]}"

   if ant != ff[0] 
     puts "---------------------"
     ant = ant.sub(/\./,'')
      
     puts "nuevo codigo #{ant} texto -----> (#{buffer}) "
     if (ant != "")
       fo.puts("update perfiles set ayuda = '#{buffer}' where codigo = '#{ant}';")
     end
     puts "---------------------"
     ant = ff[0]
     buffer = ""
     entra = 1
   end 
  end

  if ( line =~ /Esta clase no comprende(.*)/ )
    puts "a partir de esta linea no entra #{line}"
    entra = 0
  end 

  if (entra == 1) 
    buffer += line
  end

end

fo.close
file.close
