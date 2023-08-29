local composer = require("composer")

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- O código fora das funções de evento de cena abaixo será executado apenas UMA VEZ, 
-- a menos que a cena seja totalmente removida (não reciclada) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local physics = require("physics")
physics.start()
physics.setGravity(0, 0)
physics.setDrawMode("normal")
-- physics.setDrawMode("hybrid")
-- physics.setDrawMode("debug")

local vidas = 3
local alimentos = 0
local vidasText
local alimentosText
local backGroup
local mainGroup
local UIGroup
local peixe
local sujeira
local morto
local alimentosTable = {}
local sujeirasTable = {}
local alimentando
local sujando
local fundo
local gameOver

-- função para atualizar a vida e pontuação
local function atualizarText()
    vidasText.text = "Vidas: " .. vidas
    alimentosText.text = "Alimentos: " .. alimentos
end
-- função para ir para a cena GAME OVER
local function gotoGameOver()
    composer.setVariable("scoreFinal", alimentos)
    composer.gotoScene("gameOver", {time = 1500, effect = "crossFade"})
end

local letterboxWidth = (display.actualContentWidth - display.contentWidth) / 2
local letterboxHeight = (display.actualContentHeight - display.contentHeight) /
                            2

local chao = display.newRect(display.contentCenterX,
                             display.contentHeight + 60 + letterboxHeight, 440,
                             120)
physics.addBody(chao, "static")
chao.myName = "Chao"
-- Para não deixar o player sair fora da tela 
local parede1 = display.newRect(-10, 50, 5, 1665)
physics.addBody(parede1, "static")
local parede2 = display.newRect(330, 290, 5, 1665)
physics.addBody(parede2, "static")

peixe = display.newImageRect("imagens/player.png", 500/7, 500/7)
peixe.x, peixe.y = 160, 400
physics.addBody(peixe, "dynamic",
                {density = 10, friction = 0.3, bounce = 0.2, radius = 25})
peixe.myName = "Peixe"
-- função para movimentação do player 
local function moverPeixe(event)
    local body = event.target
    local phase = event.phase

    if ("began" == phase) then
        display.getCurrentStage():setFocus(body, event.id)
        body.isFocus = true
        body.tempJoint = physics.newJoint("touch", body, event.x, event.y)
        body.isFixedRotation = true
    elseif (body.isFocus) then
        if ("moved" == phase) then
            body.tempJoint:setTarget(event.x, event.y)
        elseif ("ended" == phase or "cancelled" == phase) then
            display.getCurrentStage():setFocus(body, nil)
            body.isFocus = false
            event.target:setLinearVelocity(0, 0)
            event.target.angularVelocity = 0
            body.tempJoint:removeSelf()
            body.isFixedRotation = true -- para o player não girar 
        end
    end
    return true
end
peixe:addEventListener("touch", moverPeixe)
peixe:toFront()
-- função para criar os alimentos
local function criarAlimentos()
    local novoAlimento = display.newImageRect("imagens/camarao.png", 178 / 4,
                                              133 / 4)
    -- Incluindo o alimento na tabela.
    table.insert(alimentosTable, novoAlimento)
    physics.addBody(novoAlimento, "dynamic", {radius = 15, bounce = 0.8})
    novoAlimento.myName = "Alimentos"

    local localizacao = math.random(3)

    if (localizacao == 1) then
        novoAlimento.x = -60
        novoAlimento.y = math.random(500)
        novoAlimento:setLinearVelocity(math.random(40, 120), math.random(20, 60))

    elseif (localizacao == 2) then
        novoAlimento.x = math.random(display.contentWidth)
        novoAlimento.y = -60
        novoAlimento:setLinearVelocity(math.random(-40, 40),
                                       math.random(40, 120))

    elseif (localizacao == 3) then
        novoAlimento.x = display.contentWidth + 60
        novoAlimento.y = math.random(500)
        novoAlimento:setLinearVelocity(math.random(-120, -40),
                                       math.random(20, 60))
    end
    novoAlimento:applyTorque(math.random(-1, 1))
end
-- função para criar as sujeiras (garrafas pets)
local function criarSujeiras()
    local novaSujeira = display.newImageRect("imagens/gPlastica.png", 100 / 5,
                                             218 / 5)
    -- Incluindo o alimento na tabela.
    table.insert(alimentosTable, novaSujeira)
    physics.addBody(novaSujeira, "dynamic", {radius = 18, bounce = 0.8})
    novaSujeira.myName = "Sujeiras"

    local localizacao = math.random(3)

    if (localizacao == 1) then
        novaSujeira.x = -60
        novaSujeira.y = math.random(500)
        novaSujeira:setLinearVelocity(math.random(40, 120), math.random(20, 60))

    elseif (localizacao == 2) then
        novaSujeira.x = math.random(display.contentWidth)
        novaSujeira.y = -60
        novaSujeira:setLinearVelocity(math.random(-40, 40), math.random(40, 120))

    elseif (localizacao == 3) then
        novaSujeira.x = display.contentWidth + 60
        novaSujeira.y = math.random(500)
        novaSujeira:setLinearVelocity(math.random(-120, -40),
                                      math.random(20, 60))
    end

    novaSujeira:applyTorque(math.random(-1, 1))

end

local function gameLoop()
    criarAlimentos()

    for i = #alimentosTable, 1, -1 do
        local thisAlimento = alimentosTable[i]

        if (thisAlimento.x < -100 or thisAlimento.x > display.contentWidth + 100 or
            thisAlimento.y < -100 or thisAlimento.y > display.contentHeight +
            100) then
            display.remove(thisAlimento)
            table.remove(alimentosTable, i)
        end
    end
end

local function gameLoopS()
    criarSujeiras()

    for i = #sujeirasTable, 1, -1 do
        local thisSujeira = sujeirasTable[i]

        if (thisSujeira.x < -100 or thisSujeira.x > display.contentWidth + 100 or
            thisSujeira.y < -100 or thisSujeira.y > display.contentHeight + 100) then
            display.remove(thisSujeira)
            table.remove(sujeirasTable, i)
        end
    end
end
-- função para restaurar o player quando perde uma vida
local function restauraPeixe()

    peixe.isBodyActive = false
    peixe.x = display.contentCenterX
    peixe.y = display.contentHeight - 100

    transition.to(peixe, {
        alpha = 1,
        time = 1500,
        onComplete = function()
            peixe.isBodyActive = true
            morto = false
        end
    })
end
-- função das colisões do JOGO
local function onCollision(event)
    if (event.phase == "began") then
        local obj1 = event.object1
        local obj2 = event.object2

        if ((obj1.myName == "Alimentos" and obj2.myName == "Chao") or
            (obj1.myName == "Chao" and obj2.myName == "Alimentos")) then
            
            if (obj1.myName == "Alimentos") then
                display.remove(obj1)
            else
                display.remove(obj2)
            end

            for i = #alimentosTable, 1, -1 do
                if (alimentosTable[i] == obj1 or alimentosTable[i] == obj2) then
                    table.remove(alimentosTable, i)
                    break
                end -- if alimentosTable
            end -- if do FOR

        elseif ((obj1.myName == "Alimentos" and obj2.myName == "Peixe") or
            (obj1.myName == "Peixe" and obj2.myName == "Alimentos")) then
            if (obj1.myName == "Alimentos") then
                display.remove(obj1)
            else
                display.remove(obj2)
            end
            audio.setVolume(0.3)
            audio.play(alimentando)
            for i = #alimentosTable, 1, -1 do
                if (alimentosTable[i] == obj1 or alimentosTable[i] == obj2) then
                    table.remove(alimentosTable, i)
                    break
                end
            end
            alimentos = alimentos + 1
            alimentosText.text = "Alimentos: " .. alimentos

        elseif ((obj1.myName == "Sujeiras" and obj2.myName == "Peixe") or
            (obj1.myName == "Peixe" and obj2.myName == "Sujeiras")) then
            if (obj1.myName == "Peixe") then
                vidas = vidas - 1
                vidasText.text = "Vidas: " .. vidas
                audio.setVolume(0.1)
                audio.play(sujando)
                peixe.alpha = 0
                timer.performWithDelay(10, restauraPeixe)
            else
                vidas = vidas - 1
                vidasText.text = "Vidas: " .. vidas
                audio.setVolume(0.1)
                audio.play(sujando)
                peixe.alpha = 0
                timer.performWithDelay(10, restauraPeixe)
            end

            if (morto == false) then
                morto = true

                if (vidas <= 0) then
                    display.remove(peixe)
                    for i = #alimentosTable, 1, -1 do
                        display.remove(alimentosTable[i])
                        table.remove(alimentosTable, i)
                    end
                    for i = #sujeirasTable, 1, -1 do
                        display.displayremove(sujeirasTable[i])
                        table.remove(sujeirasTable, i)
                    end

                    composer.setVariable("scoreFinal", alimentos)
                    gotoGameOver()
                    
                end
            end

        end -- if pontos alimentação

    end -- if event.phase
end -- function

Runtime:addEventListener("collision", onCollision)

-- -----------------------------------------------------------------------------------
-- Funções de evento de cena
-- -----------------------------------------------------------------------------------

-- create() "criar"
function scene:create(event)

    local sceneGroup = self.view
    -- O código aqui é executado quando a cena é criada pela primeira vez, mas ainda não apareceu na tela
    physics.pause()

    backGroup = display.newGroup()
    sceneGroup:insert(backGroup)
    mainGroup = display.newGroup()
    sceneGroup:insert(mainGroup)
    UIGroup = display.newGroup()
    sceneGroup:insert(UIGroup)

    local bg1 = display.newImageRect(backGroup, "imagens/fundo3.png", 1824, 852)
    bg1.x, bg1.y = 160, 0
    bg1.xScale = 1
    bg1.yScale = 1
    transition.to(bg1, {time = 20000, x = -150, iterations = 0})

    local bg2 = display.newImageRect(backGroup, "imagens/fundo3.png", 1824, 852)
    bg2.x, bg2.y = 360, 240
    bg2.xScale = 1
    bg2.yScale = 1
    transition.to(bg2, {time = 20000, x = -500, iterations = 0})
    
    audio.setVolume(0.1, {channel = 1})
    fundo = audio.loadStream("audios/fAgua.wav")
    alimentando = audio.loadSound("audios/bolha.wav")
    sujando = audio.loadSound("audios/erro.wav")
    vidasText = display.newText(UIGroup, "Vidas: " .. vidas,
                                display.contentCenterX - 100, -80,
                                native.systemFont, 18)
    
    alimentosText = display.newText(UIGroup, "Alimentos: " .. alimentos,
                                    display.contentCenterX + 10, -80,
                                    native.systemFont, 18)
end

-- show() "mostrar"
function scene:show(event)

    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        -- Ocorre imediatamente antes da cena aparecer na tela.

    elseif (phase == "did") then
        -- Ocorre imediatamente após a cena aparecer na tela.
        physics.start()
        gameLoopTimer = timer.performWithDelay(700, gameLoop, 0)
        gameLoopSTimer = timer.performWithDelay(700, gameLoopS, 0)
        audio.play(fundo, {channel = 1, loops = -1})
    end
end

-- hide() "esconder"
function scene:hide(event)

    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        -- Ocorre imediatamente antes da cena sair da tela.

        timer.cancel(gameLoopTimer)
        timer.cancel(gameLoopSTimer)

    elseif (phase == "did") then
        -- Ocorre imediatamente após a cena sair da tela.
        physics.pause()
        composer.removeScene("game")

        audio.stop(1)
        Runtime:removeEventListener("enterFrame", moverPeixe)
        Runtime:removeEventListener("collision", onCollision)
        
    end
end

-- destroy() "destruir"
function scene:destroy(event)

    local sceneGroup = self.view
    -- Ocorre quando a cena é destruída.
    audio.dispose(alimentando)
    audio.dispose(sujando)
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
