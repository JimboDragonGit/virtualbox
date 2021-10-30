current_dir = File.dirname __FILE__

cookbook = File.dirname current_dir
vendor = File.join(File.dirname(cookbook), "berks_vendor")

puts "cookbook_path = #{cookbook}"
puts "vendor = #{vendor}"
cookbook_path [
                cookbook, vendor
              ]
