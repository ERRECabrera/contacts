module Response

  def json_response(object,**json_options)
    response = {json: object}.merge(json_options)
    render response
  end

end