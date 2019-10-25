class ConverteJsonToXmlController < ApplicationController
  respond_to :xml, :json
  def converte
    if params[:dados_json].present?
      result = Oj.load(params[:dados_json])
      send_data result.to_xml(root: "xml"), type: "text/xml", disposition: "inline"
    end
  end
end