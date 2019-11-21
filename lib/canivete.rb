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


def valida_modelo(vModelo)
  @modelos.include?(vModelo.upcase)
end


def tratar_linha(linha)
  linha = linha.strip unless linha.nil?
  if linha.match(/.*\;.*activate.*\".*\"/i) or 
    linha.match(/.*\;.*new_instance.*\".*\".*\,/i) or 
    linha.match(/.*\;.*newinstance.*\".*\".*\,/i) or
    linha.match(/.*\;.*selectdb.*from.*\".*\"/i) or
    linha.match(/.*\;.*sql/i)
    linha = ""
  else
    linha = linha.gsub("\%\\", "")
  end
end



def nome_arquivo(vArquivo)
  vNome = ""
  s1 = vArquivo.index(@ultimo_diretorio)+12   #@ultimo_diretorio
  if vArquivo.include?(".menlst")
    s2 = vArquivo.index("@")-1
    vNome = vArquivo[s1..s2]
  else
    s2 = vArquivo.index(".")-1
    vNome = vArquivo[s1..s2]
  end
  vNome
end