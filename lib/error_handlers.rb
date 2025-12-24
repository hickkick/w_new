module ErrorHandlers
  def self.registered(app)
    app.not_found do
      @path = request.path
      @method = request.request_method
      erb :error_404
    end
  end
end
