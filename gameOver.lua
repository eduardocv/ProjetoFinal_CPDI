local composer = require("composer")
local scene = composer.newScene()

-- COLOCAR áudio no gameOver
local fundo
audio.setVolume(0.5, {channel = 1})
-- função para ir para a cena do JOGO
local function gotoGame()
    composer.gotoScene("game", {time = 800, effect = "crossFade"})
end
-- função para ir para a cena dos RECORDES
local function gotoRecordes()
    composer.gotoScene("recordes", {time = 800, effect = "crossFade"})
 end
-- função para ir para a cena do MENU
local function gotoMenu()
    composer.gotoScene("menu", {time = 800, effect = "crossFade"})
end
-----------------------------------------------------------------------------------------
-- O código fora das funções de evento de cena abaixo será executado apenas UMA VEZ,
-- a menos que a cena seja totalmente removida (não reciclada) via "composer.removeScene()"
-----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------
-- Funções de evento de cena
-- -----------------------------------------------------------------------------------

-- create() "criar"
-- O código aqui é executado quando a cena é criada pela primeira vez, mas ainda não apareceu na tela
function scene:create(event)

    local sceneGroup = self.view
    local bg = display.newImageRect(sceneGroup, "imagens/fundoGameOver.jpg", 1904/4, 2544/3)
    bg.x, bg.y = display.contentCenterX, display.contentCenterY

   
    local gameOverImage = display.newImageRect(sceneGroup, "imagens/gameOver.png", 640*0.85, 360*0.85)
    gameOverImage.x, gameOverImage.y = display.contentCenterX, display.contentCenterY-100

    -- Botão para entrar na cena do JOGO novamente 
    local playButton = display.newRoundedRect (sceneGroup, 160, 300, 200 ,45, 10)
    playButton:setFillColor (0, 0, 255)
    local play = display.newText(sceneGroup, "Jogar", display.contentCenterX,
                                 300, native.systemFontBold, 40)
    play:setFillColor(255, 255, 255)
    -- Botão para entrar na cena dos RECORDES
    local recordesButton = display.newRoundedRect (sceneGroup, 160, 350, 200 ,40, 10)
    recordesButton:setFillColor (0, 0, 255)
    local recordes = display.newText(sceneGroup, "Recordes",
                                     display.contentCenterX, 350,
                                     native.systemFontBold, 40)
    recordes:setFillColor(255, 255, 255)
    -- Botão para entrar na cena do MENU
    local menuButton = display.newRoundedRect (sceneGroup, 160, 400, 200 ,40, 10)
    menuButton:setFillColor (0, 0, 255)
    local menu = display.newText(sceneGroup, "Menu", display.contentCenterX,
                                 400, native.systemFontBold, 44)
    menu:setFillColor(255, 255, 255)
    -- Áudio de fundo 
    fundo = audio.loadStream("audios/cantoDaSereia.wav")
    -- Eventos para ir para as cenas JOGO, MENU e RECORDES
    playButton:addEventListener("tap", gotoGame)
    menuButton:addEventListener("tap", gotoMenu)
    recordesButton:addEventListener("tap", gotoRecordes)
end

-- show() "mostrar"
function scene:show(event)

    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        -- O código aqui é executado quando a cena ainda está fora da tela (mas está prestes a aparecer na tela)

    elseif (phase == "did") then
        -- O código aqui é executado quando a cena está inteiramente na tela
        audio.play(fundo, {channel = 1, loops = -1})
    end
end

-- hide() "esconder"
function scene:hide(event)

    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        -- O código aqui é executado quando a cena está na tela (mas está prestes a sair da tela)

    elseif (phase == "did") then
        -- O código aqui é executado imediatamente após a cena sair totalmente da tela
        composer.removeScene("gameOver")
        audio.stop(1)
    end
end

-- destroy() "destruir"
function scene:destroy(event)

    local sceneGroup = self.view
    -- O código aqui é executado antes da remoção da visualização da cena
    audio.dispose(fundo)
end

-- -----------------------------------------------------------------------------------
-- Ouvintes de função de evento de cena
-- -----------------------------------------------------------------------------------
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)
-- -----------------------------------------------------------------------------------

return scene
