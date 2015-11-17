post '/api/admin/news' do
  validate params
  n = News.create(:headline => params[:headline], :news_text => params[:news_text])

  content_type :json
  n.to_json

end
