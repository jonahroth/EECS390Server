get '/img/:path' do
  send_file "./assets/img/#{params[:path]}"
end

get '/img/w/:identifier' do
  w = Wallpaper.find_by(:identifier => params[:identifier])
  if w
    send_file "./assets/img/wallpapers/#{w.path}"
  else
    content_type :json
    nil.to_json
  end
end
