json.array! @funcaos, partial: 'funcaos/funcaos', as: :funcao

$('#funcaos').html('<%= escape_javascript(render("funcaos")) %>');
