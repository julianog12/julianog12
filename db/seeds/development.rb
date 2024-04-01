# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
porta = '3001'



  Configuracao.create(cd_empresa: 6, parametro: 'diretorio_listener', valor: '/vagrant/dir_proclisting/r10_coamo_des/lst')
  Configuracao.create(cd_empresa: 6, parametro: 'extensao_leitura', valor: 'all')
  Configuracao.create(cd_empresa: 6, parametro: 'ultimo_diretorio', valor: 'lst/')
  Configuracao.create(cd_empresa: 6, parametro: 'ultima_alteracao', valor: '2024 04 01 09 22 51')
  Configuracao.create(cd_empresa: 6, parametro: 'nome_arq_result', valor: 'coamo10_desenv')
  Configuracao.create(cd_empresa: 6, parametro: 'servidor_http', valor: 'http://localhost:3000/componentes')
  Configuracao.create(cd_empresa: 6, parametro: 'servidor_http_funcao', valor: 'http://localhost:3000/funcaos')

  Configuracao.create(cd_empresa: 7, parametro: 'diretorio_listener', valor: '/vagrant/dir_proclisting/r10_coamo_pro/lst')
  Configuracao.create(cd_empresa: 7, parametro: 'extensao_leitura', valor: 'all')
  Configuracao.create(cd_empresa: 7, parametro: 'ultimo_diretorio', valor: 'lst/')
  Configuracao.create(cd_empresa: 7, parametro: 'ultima_alteracao', valor: '2024 04 01 09 22 51')
  Configuracao.create(cd_empresa: 7, parametro: 'nome_arq_result', valor: 'coamo10_producao')
  Configuracao.create(cd_empresa: 7, parametro: 'servidor_http', valor: 'http://localhost:3000/componentes')
  Configuracao.create(cd_empresa: 7, parametro: 'servidor_http_funcao', valor: 'http://localhost:3000/funcaos')

  Configuracao.create(cd_empresa: 8, parametro: 'diretorio_listener', valor: '/var/coamo/unifacedes/r10_credi_des/proclisting')
  Configuracao.create(cd_empresa: 8, parametro: 'extensao_leitura', valor: 'all')
  Configuracao.create(cd_empresa: 8, parametro: 'ultimo_diretorio', valor: 'proclisting/')
  Configuracao.create(cd_empresa: 8, parametro: 'ultima_alteracao', valor: '2023 12 05 09 00 00')
  Configuracao.create(cd_empresa: 8, parametro: 'nome_arq_result', valor: 'credi10_desenv')
  Configuracao.create(cd_empresa: 8, parametro: 'servidor_http', valor: 'http://localhost:3000/componentes')
  Configuracao.create(cd_empresa: 8, parametro: 'servidor_http_funcao', valor: 'http://localhost:3000/funcaos')

  Configuracao.create(cd_empresa: 9, parametro: 'diretorio_listener', valor: '/var/coamo/unifacedes/r10_credi_pro/proclisting')
  Configuracao.create(cd_empresa: 9, parametro: 'extensao_leitura', valor: 'all')
  Configuracao.create(cd_empresa: 9, parametro: 'ultimo_diretorio', valor: 'proclisting/')
  Configuracao.create(cd_empresa: 9, parametro: 'ultima_alteracao', valor: '2023 12 05 09 00 00')
  Configuracao.create(cd_empresa: 9, parametro: 'nome_arq_result', valor: 'credi10_producao')
  Configuracao.create(cd_empresa: 9, parametro: 'servidor_http', valor: 'http://localhost:3000/componentes')
  Configuracao.create(cd_empresa: 9, parametro: 'servidor_http_funcao', valor: 'http://localhost:3000/funcaos')