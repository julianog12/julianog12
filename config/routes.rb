#require 'sidekiq/web'

Rails.application.routes.draw do    

  resources :painel, only: [:index, :show]

  #mount Sidekiq::Web => '/sidekiq'

  #get '/monitors/index', to: 'monitors#index'

  get 'heartbeat', to: 'heartbeats#index'    

  resources :funcaos   
  resources :componentes    

  post 'componentes/conversor' => 'componentes#conversor'    

  post 'converte_json_to_xml/converte' => 'converte_json_to_xml#converte'    

  post 'converter_pdf_to_imagem/converte' => 'converter_pdf_to_imagem#converte'    

  post 'converter_html_to_imagem/converte' => 'converter_html_to_imagem#converte'   
  get 'converter_html_to_imagem/exemplo' => 'converter_html_to_imagem#exemplo'    

  post 'converter_string_to_qrcode/converte' => 'converter_string_to_qrcode#converte'   
  get 'converter_string_to_qrcode/exemplo' => 'converter_string_to_qrcode#exemplo'    

  post 'converter_string_to_barcode/converte' => 'converter_string_to_barcode#converte'    

  post 'converter_html_to_pdf/converte' => 'converter_html_to_pdf#converte'   
  get 'converter_html_to_pdf/exemplo' => 'converter_html_to_pdf#exemplo'    

  post 'converter_html_to_pdf/converte' => 'converter_html_to_pdf#converte'   
  get 'converter_html_to_pdf/exemplo' => 'converter_html_to_pdf#exemplo'

  resources :diffs, only: [:show, :create, :new, :index]    

  root 'funcaos#index' 
end 
