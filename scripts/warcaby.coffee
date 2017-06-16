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
  output = '\n     1   2   3   4   5   6   7   8\n  __________________________________\n  ----------------------------------'
  i = 0
  while i < 8
    output += '\n'
    output += i + 1 + ' ||'
    j = 0
    while j < 8
      pionek = plansza[i][j]
      if !pionek
        pionek = ' '
      output += ' ' + pionek + ' |'
      j++
    output += '\n  ----------------------------------'
    i++
  output
		
planszaNowa = [["","X","","X","","X","","X"],
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
  return '[SUKCES]\n'+planszaRysuj(plansza)
	
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


	
	
	
	
#---------------- to samo tylko w JS
#
#
#var planszaRysuj = function(plansza) {
#	var output="\n    1| 2| 3| 4| 5| 6| 7| 8\n__________________________";
#
#	for (var i=0; i<8; i++){
#    output+="\n";
#    output+=i+1;
#	    for (var j=0; j<8; j++){
#        	var pionek = plansza[i][j];
#        	if (!pionek)
#          		pionek = "  ";
#	      	output += pionek + "|";
#	    }
#    output+="\n__________________________";
#	}	
#	return output;
#}
#// ruch 6,2->5,3
#
#var input = "ruch 6,2->5,3";
#
#var inputPoprawny = function(input) {
#  if (input.indexOf("->") !== -1)
#    return true;
#  return false;
#};
#var podzielInput = function(input) {
#  var output = input.split("->");
#	return output;
#};
#var obiePozycjePoprawne = function(input) {
#  for (var i in input){
#    if (input[i].indexOf(",") === -1)
#      return false;
#  }
#  return true;
#};
#var podzielPozycjeNaXiY = function(input) {
#  var output = input.split(",");
#	return output;  
#};
#var PoleJestPuste = function(input) {
#  if (!input)
#    return true;
#  return false;
#};
#var poleJestZajetePrzezObcyPionek = function(input) {
#  if (input === "X")
#    return true;
#  return false;
#};
#
#//----------
#
#var graczWykonujeRuch = function() {
#  var pozycjaStartowa;
#  var pozycjaWynikowa;
#  
#  if (!inputPoprawny)
#    return res.send("Niepoprawny format. Pozycja oryginalna i wynikowa muszą być rozdzielone za pomocą -> .");
#  var pozycja = podzielInput(input);
#  if (!obiePozycjePoprawne(pozycja))
#    return res.send("Niepoprawny format. Pozycja X i Y pionka muszą być rozdzielone za pomocą przecinka.");
#  
#  pozycjaStartowa = podzielPozycjeNaXiY(pozycja[0]);
#  pozycjaWynikowa = podzielPozycjeNaXiY(pozycja[1]);
#  
#  if (poleJestPuste(plansza[pozycjaStartowa]))
#		return res.send("Wybrane pole startowe jest puste!");
#  if (poleJestZajetePrzezObcyPionek(plansza[pozycjaStartowa]))
#    return res.send("Wybrane pol startowe jest zajete przez obcy pionek!");
#  
#  res.send("Sukces!");
#};