local composer = require("composer")

local scene = composer.newScene()

local fundo
audio.setVolume(1, {channel = 1})
-- -----------------------------------------------------------------------------------
-- O código fora das funções de evento de cena abaixo será executado apenas UMA VEZ, 
-- a menos que a cena seja totalmente removida (não reciclada) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
-- chama biblioteca json para a cena
local json = require("json")
local alimentosTable = {}
local filePath = system.pathForFile("pontos.json", system.DocumentsDirectory)

local function carregaPontos()
    local pasta = io.open(filePath, "r") -- "r" == somente leitura

    if pasta then
        local contents = pasta:read("*a")
        io.close(pasta) -- fechar o arquivo
        alimentosTable = json.decode(contents)
    end
    if (alimentosTable == nil or #alimentosTable == 0) then
        alimentosTable = {350, 200, 170, 115, 55, 35, 20, 10, 5, 1} -- define as pontuações iniciais
    end
end

local function salvaPontos()
    for i = #alimentosTable, 11, -1 do
        table.remove(alimentosTable, i) -- remove os dados 11 acima
    end
    local pasta = io.open(filePath, "w") -- "w" == acesso à escrita (gravação)

    if pasta then
        pasta:write(json.encode(alimentosTable))
        io.close(pasta) -- fecha o arquivo pontos.json
    end
end

local function gotoMenu()
    composer.gotoScene("menu", {time = 800, effect = "crossFade"})
end

-- -----------------------------------------------------------------------------------
-- Funções de evento de cena
-- -----------------------------------------------------------------------------------

-- create() "criar"
function scene:create(event)

    local sceneGroup = self.view
    -- O código aqui é executado quando a cena é criada pela primeira vez, mas ainda não apareceu na tela
    carregaPontos() -- executa a função que extrai as pontuações anteriores

    table.insert(alimentosTable, composer.getVariable("scoreFinal"))

    composer.setVariable("scoreFinal", 0) -- redefine o valor da variável

    local function compare(a, b) return a > b end

    table.sort(alimentosTable, compare)
    salvaPontos()

    -- local bg = display.newImageRect(sceneGroup, "imagens/fundo2.png", 1558, 852)
    local bg = display.newImageRect(sceneGroup, "imagens/fundoRecordes.png", 560*0.85, 852*0.85)
    bg.x, bg.y = display.contentCenterX, display.contentCenterY

    local cabecalho = display.newImageRect(sceneGroup, "imagens/recordes.png", 686*0.45, 250/2)
    cabecalho.x, cabecalho.y = display.contentCenterX, display.contentCenterY -170

    cabecalho:setFillColor(1)

    for i = 1, 10 do
        if (alimentosTable[i]) then
            local yPos = 110 + (i * 26)

            local ranking = display.newText(sceneGroup, i .. "°",
                                            display.contentCenterX - 50, yPos,
                                            native.systemFontBold, 24)
            ranking:setFillColor(255, 215, 0)
            ranking.anchorX = 1

            local finalPontos = display.newText(sceneGroup, alimentosTable[i],
                                                display.contentCenterX - 30,
                                                yPos, native.systemFontBold, 24)
            finalPontos:setFillColor(1)
            finalPontos.anchorX = 0
        end
    end

    fundo = audio.loadStream("audios/cantoDaSereia.wav")

    -- Botão para entrar na cena do MENU
    local menuButton = display.newRoundedRect(sceneGroup, 160, 480, 200, 40, 10)
    menuButton:setFillColor(0, 0, 255)
    local menu = display.newText(sceneGroup, "Menu", display.contentCenterX,
                                 480, native.systemFontBold, 40)
    menu:setFillColor(255, 255, 255)

    menuButton:addEventListener("tap", gotoMenu)

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
        composer.removeScene("recordes")
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
