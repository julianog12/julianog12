if Rails.env == 'production'
  #vCoDesenv  = "echo Utilid@de5 | sudo -S mount -t cifs //admis16i/UnifaceDes/R96_coamo_des/Proclisting  /var/coamo/unifacedes/r96_coamo_des/proclisting -o username=uniface_user,password=fatserver,workgroup=coamo,uid=root,gid=root"
  #vCoProd    = "echo Utilid@de5 | sudo -S mount -t cifs //admis16i/UnifaceDes/R96_coamo_pro/Proclisting  /var/coamo/unifacedes/r96_coamo_pro/proclisting -o username=uniface_user,password=fatserver,workgroup=coamo,uid=root,gid=root"

  vCoDesenv  = "echo Utilid@de5 | sudo -S mount -t cifs //admis19u/UnifaceDev/Corporativo/R10_coamo_des/lst /var/coamo/unifacedes/r10_coamo_des/proclisting -o username=uniface_user,password=fatserver,workgroup=coamo,uid=root,gid=root"
  vCoProd    = "echo Utilid@de5 | sudo -S mount -t cifs //admis19u/UnifaceDev/Corporativo/R10_coamo_pro/lst /var/coamo/unifacedes/r10_coamo_pro/proclisting -o username=uniface_user,password=fatserver,workgroup=coamo,uid=root,gid=root"

  vCreDesenv = "echo Utilid@de5 | sudo -S mount -t cifs //admis16i/UnifaceDes/R97_credi_dsv/Proclisting  /var/coamo/unifacedes/r97_credi_dsv/proclisting -o username=uniface_user,password=fatserver,workgroup=coamo,uid=root,gid=root"
  vCreProd   = "echo Utilid@de5 | sudo -S mount -t cifs //admis16i/UnifaceDes/R97_credi_pro/Proclisting  /var/coamo/unifacedes/r97_credi_pro/proclisting -o username=uniface_user,password=fatserver,workgroup=coamo,uid=root,gid=root"

  vContabCrediProd = "echo Utilid@de5 | sudo -S mount -t cifs  //admis16i/UnifaceDes/r97_crctb_pro/Proclisting /var/coamo/unifacedes/r97_crctb_pro/proclisting -o username=uniface_user,password=fatserver,workgroup=coamo,uid=root,gid=root"

  vSeguradoras = "echo Utilid@de5 | sudo -S mount -t cifs //admfs03/Uniface/Coamo/Arquivos/seguradoras /var/coamo/fsuniface/coamo/arquivos/seguradoras -o username=uniface_user,password=fatserver,workgroup=coamo,uid=root,gid=root"

  system vCoDesenv
  system vCoProd
  system vCreDesenv
  system vCreProd
  system vSeguradoras
end