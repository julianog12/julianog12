require "application_system_test_case"

class FuncaosTest < ApplicationSystemTestCase
  setup do
    @funcao = funcaos(:one)
  end

  test "visiting the index" do
    visit funcaos_url
    assert_selector "h1", text: "Funcaos"
  end

  test "creating a Funcao" do
    visit funcaos_url
    click_on "New Funcao"

    fill_in "Codigo", with: @funcao.codigo
    fill_in "Componente", with: @funcao.componente_id
    fill_in "Tipo", with: @funcao.tipo
    click_on "Create Funcao"

    assert_text "Funcao was successfully created"
    click_on "Back"
  end

  test "updating a Funcao" do
    visit funcaos_url
    click_on "Edit", match: :first

    fill_in "Codigo", with: @funcao.codigo
    fill_in "Componente", with: @funcao.componente_id
    fill_in "Tipo", with: @funcao.tipo
    click_on "Update Funcao"

    assert_text "Funcao was successfully updated"
    click_on "Back"
  end

  test "destroying a Funcao" do
    visit funcaos_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Funcao was successfully destroyed"
  end
end
