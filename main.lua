-----------------------------------------------------------------------------------------
------------------------- Projeto final para o curso ------------------------------------
-------------------------------- Integrantes: -------------------------------------------
------- Arthur Romanovas, Danieli H. Ferreira, Diego Souza e Eduardo C. Vieira ----------
-------------------------------- Versão: 1.1 --------------------------------------------
-----------------------------------------------------------------------------------------
local composer = require("composer")

display.setStatusBar(display.HiddenStatusBar)

math.randomseed(os.time())

-- inserindo áudio do MENU
audio.reserveChannels(1)
audio.setVolume(0.5, {channel = 1})
-- já inicia na cena do MENU
composer.gotoScene("menu")
-- composer.gotoScene ("game")
-- composer.gotoScene ("recordes")
-- composer.gotoScene ("gameOver")


-----------------------------------------------------------------------------------------
--------------------- MELHORIAS para a próxima versão (v1.2) ----------------------------
-- 1ª) utilização de Sprite no player (não encontramos nenhuma decente);
-- 2ª) limitação de movimentação do player (sem utilização de obstáculos estáticos);
-- 3ª) fazer com que os objetos (garrafas pets) sumam após alguns minutos pós aparições;
-- 4ª) criação de informativos pertinentes para melhorias na vida na água;
-----------------------------------------------------------------------------------------