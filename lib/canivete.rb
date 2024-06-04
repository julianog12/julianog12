#sudo mount -t cifs //admis16i/UnifaceDes/R96_coamo_des/Proclisting /var/coamo/UnifaceDes/R96_coamo_des/Proclisting -o username=uniface_user,password=fatserver,workgroup=coamo,uid=root,gid=root
#sudo mount -t cifs //admis16i/UnifaceDes/r96_coamo_pro/Proclisting /var/coamo/UnifaceDes/R96_coamo_pro/Proclisting -o username=uniface_user,password=fatserver,workgroup=coamo,uid=root,gid=root


  def modelos(vConexao, vUserBanco)
    vModelos = [] 
    #Busca os modelos
    v_sql = "select rtrim(u_vlab) models 
  				from #{vUserBanco}.ucsch
  		   where rtrim(u_vlab) not in('APS', 'ARH', 'CNF', 'CCN')
  		     and length(trim(u_vlab)) = 4
  		   order by rtrim(u_vlab)"
    cursor_models = @conn.parse(v_sql)
    begin
      cursor_models.exec
      while r = cursor_models.fetch()
        vModelos << r[0]
      end
    rescue Exception => e
     puts "Erro #{e.inspect}"
     return
    end
    vModelos
  end
  
  def valida_fora_padrao(vApenasNome, vArquivo, vModel, vModelos)
    if (vApenasNome.include?("_") | vApenasNome.length != 8) & (!(vArquivo.to_s.include?(".menlst")) & !(vArquivo.to_s.include?(".apslst"))) &
      ((File.open(vArquivo).read.scan(/newinstance\s/i).count == 0) && 
      (File.open(vArquivo).read.scan(/new_instance\s/i).count == 0) && 
      (File.open(vArquivo).read.scan(/activate\s/i).count == 0) &&
      (File.open(vArquivo).read.scan(/activate\/stateless/i).count  == 0) &&
      (File.open(vArquivo).read.scan(/selectdb\s/i).count == 0) && 
      (File.open(vArquivo).read.scan(/sql/i).count == 0))
      return false
    elsif (!vModelos.include?(vModel.upcase)) & (!(vArquivo.to_s.include?(".menlst")) & !(vArquivo.to_s.include?(".apslst")))
      return false
    end
    true
  end
  

  
  def valida_modelo(v_modelo)
    @modelos.include?(v_modelo.upcase)
  end
  

  def inicio_fim_linha(linha)
    v1 = linha.index("\n")
    if v1.nil?
      vLinha = linha[26..300]
    else
      v1 -= 1
      vLinha= linha[26..v1]
    end
    [vLinha, v1]
  end



  def tratar_linha(v_linha)
    return if v_linha.nil?
    v_linha = v_linha.strip
    if v_linha == 'activate'
      v_linha = ''
    end
    if v_linha.match(/.*\;.*activate.*\".*\"/i) or 
      v_linha.match(/.*\;.*new_instance.*\".*\".*\,/i) or 
      v_linha.match(/.*\;.*newinstance.*\".*\".*\,/i) or
      v_linha.match(/.*\;.*selectdb.*from.*\".*\"/i) or
      v_linha.match(/.*\;.*sql/i) or
      v_linha.match(/include lib_coamo:g_vld_activate/i)
      v_linha = ''
    else
      v_linha = v_linha.gsub("\%\\", '')
    end
  end
  


  def nome_modelo(componente)
    v_model = ''
    case componente[0..2]
    when 'ccn', 'cnf', 'arh'
      v_model = componente[0..2]
    else
      v_model = componente[0..3]
    end
    v_model
  end
  
  
  def nome_arquivo(v_arquivo)
    v_nome = '' 
    s1 = v_arquivo.index(@ultimo_diretorio)+(@ultimo_diretorio.length)   #@ultimo_diretorio
    if v_arquivo.include?('.menlst')
      s2 = v_arquivo.index('@')-1
      v_nome = v_arquivo[s1..s2]
    else
      s2 = v_arquivo.index('.')-1
      v_nome = v_arquivo[s1..s2]
    end
    v_nome
  end
