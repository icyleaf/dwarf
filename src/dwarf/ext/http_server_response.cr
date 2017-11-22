class HTTP::Server::Response
  property headers : HTTP::Headers

  # Redirect to url in response
  def redirect_to(url : String, permanent = false)
    @headers.add "Location", url
    @status_code = permanent ? 301 : 302
  end

  def headers(headers : HTTP::Headers)
    @headers = headers
  end

  def status_code(code : Int32)
    @status_code = code
  end
end
