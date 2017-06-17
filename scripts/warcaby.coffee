# Description:
#   Warcaby.
#
# Notes:
#   Warcaby.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md
#-----------------------------------------------------------

module.exports = (warcabot) ->
	
	warcabot.respond /gra/i, (res) ->
		res.send planszaRysuj(planszaNowa)
	warcabot.respond /pomoc/i, (res) ->
		res.send ("\nJesteś graczem białym. Można poruszać pionkami tylko po skosie. "+
			"\nPrzegrywa ten, kto stracił wszystkie pionki."+
			"\n\nPoruszanie się za pomocą komendy \"ruch x,y -> a,b\" . Przykład: ruch 6,3 -> 5,4")
	warcabot.respond /ruch (.*)/i, (res) ->
		res.send(graczWykonujeRuch(res.match[1]))
	warcabot.respond /test/i, (res) ->
		res.send '☺️'
#----------------------------------------------------------------------

planszaRysuj = (plansza) ->
  output = ':black_large_square::one::two::three::four::five::six::seven::eight::black_large_square:'
  i = 0
  while i < 8
    output += '\n' + zamienLiczbyNaEmoji(i + 1)
    j = 0
    while j < 8
      if plansza[i][j] == 'X'
        output += ':black_circle:'
      if plansza[i][j] == 'X*'
        output += ':large_blue_circle:'
      if plansza[i][j] == 'O'
        output += ':white_circle:'
      if plansza[i][j] == 'O*'
        output += ':red_circle:'
      if plansza[i][j] == ''
        if (i + j) % 2 == 0
          output += ':white_large_square:'
        else
          output += ':black_large_square:'
      j++
    output += zamienLiczbyNaEmoji(i + 1)
    i++
  output + '\n:black_large_square::one::two::three::four::five::six::seven::eight::black_large_square:\n'

planszaNowa = 
	[["","X","","X","","X","","X"],
	["X","","X","","X","","X",""],
	["","X","","X","","X","","X"],
	["","","","","","","",""],
	["","","","","","","",""],
	["O","","O","","O","","O",""],
	["","O","","O","","O","","O"],
	["O","","O","","O","","O",""]]

graczWykonujeRuch = (input) ->
  plansza=planszaNowa
  pozycjaStartowa = undefined
  pozycjaWynikowa = undefined
  if !inputRozdzielonyStrzalka(input)
    return '[BŁĄD] Niepoprawny format. Pozycja oryginalna i wynikowa muszą być rozdzielone za pomocą -> .'
  pozycja = podzielInput(input)
  if !obiePozycjeRozdzielonePrzecinkiem(pozycja)
    return '[BŁĄD] Niepoprawny format. Pozycja X i Y pionka muszą być rozdzielone za pomocą przecinka.'
  pozycjaStartowa = podzielPozycjeNaXiY(pozycja[0])
  pozycjaWynikowa = podzielPozycjeNaXiY(pozycja[1])
  if !pozycjePoprawne(pozycjaStartowa)
    return '[BŁĄD] Pozycja '+pozycjaStartowa+' nie istnieje.'
  if !pozycjePoprawne(pozycjaWynikowa)
    return '[BŁĄD] Pozycja '+pozycjaWynikowa+' nie istnieje.'
  if poleJestPuste(plansza[pozycjaStartowa[0]-1][pozycjaStartowa[1]-1])
    return '[BŁĄD] Wybrane pole startowe jest puste!'
  if poleJestZajetePrzezObcyPionek(plansza[pozycjaStartowa[0]-1][pozycjaStartowa[1]-1])
    return '[BŁĄD] Wybrane pole startowe jest zajete przez obcy pionek!'
  if !poleJestPuste(plansza[pozycjaWynikowa[0]-1][pozycjaWynikowa[1]-1])
    return '[BŁĄD] Wybrane pole wynikowe jest zajęte!'
  if wybranePoleNieSpelniaZasadGry(pozycjaStartowa, pozycjaWynikowa)
    return 'Ruch niezgodny z zasadami!'
	
  plansza=zupdatujPlanszeNaPodstawiePozycjiStartowejIWynikowejOrazGracza(plansza, pozycjaStartowa, pozycjaWynikowa, "O")
  return '[SUKCES]\n'+planszaRysuj(plansza)
  
zupdatujPlanszeNaPodstawiePozycjiStartowejIWynikowejOrazGracza = (plansza, pozycjaStartowa, pozycjaWynikowa, gracz) ->
  plansza[pozycjaWynikowa[0] - 1][pozycjaWynikowa[1] - 1] = plansza[pozycjaStartowa[0] - 1][pozycjaStartowa[1] - 1]
  plansza[pozycjaStartowa[0] - 1][pozycjaStartowa[1] - 1] = ''
  plansza
#-------------------------------------------------------------------------------------
  
inputRozdzielonyStrzalka = (input) ->
  if input.indexOf('->') != -1
    return true
  false

podzielInput = (input) ->
  output = input.split('->')
  output

pozycjePoprawne = (input) ->
  for i of input
    if input[i] < 1 or input[i] > 8
      return false
  true

obiePozycjeRozdzielonePrzecinkiem = (input) ->
  for i of input
    if input[i].indexOf(',') == -1
      return false
  true
  
podzielPozycjeNaXiY = (input) ->
  output = input.split(',')
  output

poleJestPuste = (input) ->
  if !input
    return true
  false

poleJestZajetePrzezObcyPionek = (input) ->
  if input == 'X'
    return true
  false

wybranePoleNieSpelniaZasadGry = (pozycjaStartowa, pozycjaWynikowa) ->
  false

#------------------------------------------------------------------------------------- 
  
zamienLiczbyNaEmoji = (input) ->
  switch input
    when 1
      return ':one:'
    when 2
      return ':two:'
    when 3
      return ':three:'
    when 4
      return ':four:'
    when 5
      return ':five:'
    when 6
      return ':six:'
    when 7
      return ':seven:'
    when 8
      return ':eight:'
    else
      return ':black_large_square:'
  return