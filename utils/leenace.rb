
#!/usr/bin/ruby -w

file = File.new("nace07.csv", "r")
fo = File.new("nace07.sql", "w")

while (line = file.gets)

     cc = line.split("|")
     fo.puts("insert into perfiles (`codigo`, `desc`, `nivel`) values ('#{cc[0]}', '#{cc[1].chomp}', #{cc[0].length});")
# INSERT INTO `favoritos` (`updated_at`, `created_at`, `fecha`, `nombre_empresa`, `empresa_id`, `bazar_id`, `user_id`) VALUES ('2011-03-03 21:23:35', '2011-03-03 21:23:35', '2011-03-03 21:23:35', 'Jigging Corp', 10, 2, 2)
end

fo.close
file.close
