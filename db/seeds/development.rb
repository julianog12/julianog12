# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
porta = '3001'

Configuracao.create(cd_empresa: 1, parametro: 'diretorio_listener', valor: '/vagrant/dir_proclisting/r96_coamo_des/Proclisting')
Configuracao.create(cd_empresa: 1, parametro: 'extensao_leitura', valor: 'all')
Configuracao.create(cd_empresa: 1, parametro: 'ultimo_diretorio', valor: 'Proclisting/')
Configuracao.create(cd_empresa: 1, parametro: 'ultima_alteracao', valor: '2021 03 03 12 22 51')
Configuracao.create(cd_empresa: 1, parametro: 'nome_arq_result', valor: 'coamo_desenv')
Configuracao.create(cd_empresa: 1, parametro: 'servidor_http', valor: "http://localhost:#{porta}/componentes")
Configuracao.create(cd_empresa: 1, parametro: 'servidor_http_funcao', valor: "http://localhost:#{porta}/funcaos")

Configuracao.create(cd_empresa: 2, parametro: 'diretorio_listener', valor: '/vagrant/dir_proclisting/R96_coamo_pro/Proclisting')
Configuracao.create(cd_empresa: 2, parametro: 'extensao_leitura', valor: 'all')
Configuracao.create(cd_empresa: 2, parametro: 'ultimo_diretorio', valor: 'Proclisting/')
Configuracao.create(cd_empresa: 2, parametro: 'ultima_alteracao', valor: '2021 03 03 12 22 51')
Configuracao.create(cd_empresa: 2, parametro: 'nome_arq_result', valor: 'coamo_producao')
Configuracao.create(cd_empresa: 2, parametro: 'servidor_http', valor: "http://localhost:#{porta}/componentes")
Configuracao.create(cd_empresa: 2, parametro: 'servidor_http_funcao', valor: "http://localhost:#{porta}/funcaos")

Configuracao.create(cd_empresa: 3, parametro: 'diretorio_listener', valor: '/vagrant/dir_proclisting/R96_credi_dsv/Proclisting')
Configuracao.create(cd_empresa: 3, parametro: 'extensao_leitura', valor: 'all')
Configuracao.create(cd_empresa: 3, parametro: 'ultimo_diretorio', valor: 'Proclisting/')
Configuracao.create(cd_empresa: 3, parametro: 'ultima_alteracao', valor: '2021 03 03 12 22 51')
Configuracao.create(cd_empresa: 3, parametro: 'nome_arq_result', valor: 'credi_desenv')
Configuracao.create(cd_empresa: 3, parametro: 'servidor_http', valor: "http://localhost:#{porta}/componentes")
Configuracao.create(cd_empresa: 3, parametro: 'servidor_http_funcao', valor: "http://localhost:#{porta}/funcaos")

Configuracao.create(cd_empresa: 4, parametro: 'diretorio_listener', valor: '/vagrant/dir_proclisting/r97_credi_pro/Proclisting')
Configuracao.create(cd_empresa: 4, parametro: 'extensao_leitura', valor: 'all')
Configuracao.create(cd_empresa: 4, parametro: 'ultimo_diretorio', valor: 'Proclisting/')
Configuracao.create(cd_empresa: 4, parametro: 'ultima_alteracao', valor: '2021 03 03 12 22 51')
Configuracao.create(cd_empresa: 4, parametro: 'nome_arq_result', valor: 'credi_producao')
Configuracao.create(cd_empresa: 4, parametro: 'servidor_http', valor: "http://localhost:#{porta}/componentes")
Configuracao.create(cd_empresa: 4, parametro: 'servidor_http_funcao', valor: "http://localhost:#{porta}/funcaos")

Configuracao.create(cd_empresa: 6, parametro: 'diretorio_listener', valor: '/vagrant/dir_proclisting/r10_coamo_des/lst')
  Configuracao.create(cd_empresa: 6, parametro: 'extensao_leitura', valor: 'all')
  Configuracao.create(cd_empresa: 6, parametro: 'ultimo_diretorio', valor: 'proclisting/')
  Configuracao.create(cd_empresa: 6, parametro: 'ultima_alteracao', valor: '2022 12 27 12 22 51')
  Configuracao.create(cd_empresa: 6, parametro: 'nome_arq_result', valor: 'coamo10_desenv')
  Configuracao.create(cd_empresa: 6, parametro: 'servidor_http', valor: 'http://localhost:3001/componentes')
  Configuracao.create(cd_empresa: 6, parametro: 'servidor_http_funcao', valor: 'http://localhost:3001/funcaos')