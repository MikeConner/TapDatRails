namespace :db do
  desc "Update all images"
  task :update_images => :environment do
    puts "Updating denominations" 
    Denomination.all.each do |denomination|
      if denomination.image.file.nil? or denomination.image.file.exists?
        puts "No image file for #{denomination.currency.name} / #{denomination.value}"
      else
        denomination.image.recreate_versions!
        
        puts "Updated #{denomination.currency.name} / #{denomination.value}"
      end
    end     

    puts "Updating currencies"
    Currency.all.each do |currency|
      if currency.icon.file.nil? or !currency.icon.file.exists?
        puts "No currency icon for #{currency.name}"
      else
        currency.icon.recreate_versions!
        puts "Updated #{currency.name}"
      end
    end

    puts "Updating payloads"
    Payload.all.each do |payload|
      if payload.payload_image.file.nil? or payload.payload_image.file.exists?
        puts "No payload image for #{payload.content_type} / #{payload.description}"
      else
        payload.payload_image.recreate_versions!
        puts "Updated payload #{payload.content_type} / #{payload.description}"
      end
    end     
    
    puts "Updating users"
    User.all.each do |user|
      if user.profile_image.file.nil? or user.profile_image.file.exists?
        puts "No profile image for #{user.email}"
      else
        user.profile_image.recreate_versions!
        puts "Update profile for #{user.email}"
      end
    end     
  end  
end
