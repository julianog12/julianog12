# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Configuracao.create(cd_empresa: 1, parametro: 'diretorio_listener', valor: '/vagrant/dir_proclisting/r96_coamo_des/Proclisting')
Configuracao.create(cd_empresa: 1, parametro: 'extensao_leitura', valor: 'all')
Configuracao.create(cd_empresa: 1, parametro: 'ultimo_diretorio', valor: 'Proclisting/')
Configuracao.create(cd_empresa: 1, parametro: 'ultima_alteracao', valor: '2021 03 03 12 22 51')
Configuracao.create(cd_empresa: 1, parametro: 'nome_arq_result', valor: 'coamo_desenv')
Configuracao.create(cd_empresa: 1, parametro: 'servidor_http', valor: 'http://localhost:3000/componentes')
Configuracao.create(cd_empresa: 1, parametro: 'servidor_http_funcao', valor: 'http://localhost:3000/funcaos')

Configuracao.create(cd_empresa: 2, parametro: 'diretorio_listener', valor: '/vagrant/dir_proclisting/R96_coamo_pro/Proclisting')
Configuracao.create(cd_empresa: 2, parametro: 'extensao_leitura', valor: 'all')
Configuracao.create(cd_empresa: 2, parametro: 'ultimo_diretorio', valor: 'Proclisting/')
Configuracao.create(cd_empresa: 2, parametro: 'ultima_alteracao', valor: '2021 03 03 12 22 51')
Configuracao.create(cd_empresa: 2, parametro: 'nome_arq_result', valor: 'coamo_producao')
Configuracao.create(cd_empresa: 2, parametro: 'servidor_http', valor: 'http://localhost:3000/componentes')
Configuracao.create(cd_empresa: 2, parametro: 'servidor_http_funcao', valor: 'http://localhost:3000/funcaos')

Configuracao.create(cd_empresa: 3, parametro: 'diretorio_listener', valor: '/vagrant/dir_proclisting/R96_credi_dsv/Proclisting')
Configuracao.create(cd_empresa: 3, parametro: 'extensao_leitura', valor: 'all')
Configuracao.create(cd_empresa: 3, parametro: 'ultimo_diretorio', valor: 'Proclisting/')
Configuracao.create(cd_empresa: 3, parametro: 'ultima_alteracao', valor: '2021 03 03 12 22 51')
Configuracao.create(cd_empresa: 3, parametro: 'nome_arq_result', valor: 'credi_desenv')
Configuracao.create(cd_empresa: 3, parametro: 'servidor_http', valor: 'http://localhost:3000/componentes')
Configuracao.create(cd_empresa: 3, parametro: 'servidor_http_funcao', valor: 'http://localhost:3000/funcaos')

Configuracao.create(cd_empresa: 4, parametro: 'diretorio_listener', valor: '/vagrant/dir_proclisting/r97_credi_pro/Proclisting')
Configuracao.create(cd_empresa: 4, parametro: 'extensao_leitura', valor: 'all')
Configuracao.create(cd_empresa: 4, parametro: 'ultimo_diretorio', valor: 'Proclisting/')
Configuracao.create(cd_empresa: 4, parametro: 'ultima_alteracao', valor: '2021 03 03 12 22 51')
Configuracao.create(cd_empresa: 4, parametro: 'nome_arq_result', valor: 'credi_producao')
Configuracao.create(cd_empresa: 4, parametro: 'servidor_http', valor: 'http://localhost:3000/componentes')
Configuracao.create(cd_empresa: 4, parametro: 'servidor_http_funcao', valor: 'http://localhost:3000/funcaos')
