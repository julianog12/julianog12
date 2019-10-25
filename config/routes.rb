Rails.application.routes.draw do
  
  get 'heartbeat', to: "heartbeats#index"
  
  resources :funcaos
  resources :componentes

  post "componentes/conversor" => "componentes#conversor"

  post "converte_json_to_xml/converte" => "converte_json_to_xml#converte"

  post "converter_pdf_to_imagem/converte" => "converter_pdf_to_imagem#converte"

  post "converter_html_to_imagem/converte" => "converter_html_to_imagem#converte"
  get "converter_html_to_imagem/exemplo" => "converter_html_to_imagem#exemplo"

  post "converter_string_to_qrcode/converte" => "converter_string_to_qrcode#converte"
  get "converter_string_to_qrcode/exemplo" => "converter_string_to_qrcode#exemplo"

  post "converter_string_to_barcode/converte" => "converter_string_to_barcode#converte"

  resources :diffs, only: [:show, :create, :new, :index]  

  root "componentes#index"
end
