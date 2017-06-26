# Description:
#   Warcaby.
#
# Notes:
#   Warcaby.
#-----------------------------------------------------------

module.exports = (warcabot) ->
	warcabot.respond /start/i, (res) ->
		res.send nowaGra()
	warcabot.respond /test/i, (res) ->
		res.send wrogiPionek('O')
	warcabot.respond /plansza/i, (res) ->
		if planszaZapisana == undefined
			res.send "Nie jesteś obecnie w trakcie żadnej gry."
		else res.send planszaRysuj(planszaZapisana)
	warcabot.respond /git/i, (res) ->
		res.send "https://github.com/Arcyvilk/Warcabot"
	warcabot.respond /pomoc/i, (res) ->
		res.send ("\n*Komendy:*"+
			"\n`@warcabot pomoc         `- wyświetla pomoc"+
			"\n`@warcabot start         `- rozpoczyna nową grę"+
			"\n`@warcabot plansza       `- wyświetla ostatni stan planszy, jeśli taki był"+
			"\n`@warcabot git           `- załącza link do repozytorium"+
			"\n`@warcabot ruch x,y->a,b `- ruch pionka z pozycji [X,Y] na pozycję [A,B]"+
			"\n\n*Zasady gry:*"+
			"\nJesteś graczem białym. Można poruszać pionkami tylko po skosie i tylko w przód, chyba że bijesz/grasz damką. "+
			"\nPrzegrywa ten, kto stracił wszystkie pionki."+
			"\nMożna bić tylko pojedyncze pionki, bo zabrakło mi czasu na porządne zaimplementowanie zasad.")
	warcabot.respond /ruch (.*)/i, (res) ->
		ruchGracza = graczWykonujeRuch(res.match[1])
		res.send(ruchGracza)
		if ruchGracza.indexOf('[BŁĄD]') == -1
			res.send ":hourglass: Oczekiwanie na ruch Warcabota..."
			ruchAI = aiWykonujeRuch()
			res.send ruchAI
#----------------------------------------------------------------------
	
planszaZapisana = undefined
legitneRuchy = []

nowaGra = () ->
	planszaNowa = 
		[["","X","","X","","X","","X"],
		["X","","X","","X","","X",""],
		["","X","","X","","X","","X"],
		["","","","","","","",""],
		["","","","","","","",""],
		["O","","O","","O","","O",""],
		["","O","","O","","O","","O"],
		["O","","O","","O","","O",""]]
	planszaZapisana = planszaNowa
	planszaRysuj(planszaNowa)

planszaRysuj = (plansza) ->
	output = ':black_large_square::one::two::three::four::five::six::seven::eight::black_large_square:'
	i = 0
	while i < 8
		output += '\n' + zamienLiczbyNaEmoji(i + 1)
		#output += '\n' + (i + 1) + "|"
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
			#if plansza[i][j] == 'X'
			#	output += ' X |'
			#if plansza[i][j] == 'X*'
			#	output += ' X*|'
			#if plansza[i][j] == 'O'
			#	output += ' O |'
			#if plansza[i][j] == 'O*'
			#	output += ' O*|'
			#if plansza[i][j] == ''
			#	if (i + j) % 2 == 0
			#		output += '   |'
			#	else
			#		output += '   |'
			#j++
		#output += (i + 1) + "\n-----------------------------------"
		output += zamienLiczbyNaEmoji(i + 1)
		i++
	output + '\n:black_large_square::one::two::three::four::five::six::seven::eight::black_large_square:\n'

czyKtosWygral = (plansza) ->
	liczbaBialychICzarnychPionkow = [
		0
		0
	]
	i = 0
	while i < 8
		j = 0
		while j < 8
			if plansza[i][j].indexOf('O') == 0
				liczbaBialychICzarnychPionkow[0]++
			if plansza[i][j].indexOf('X') == 0
				liczbaBialychICzarnychPionkow[1]++
			j++
		i++
	if liczbaBialychICzarnychPionkow[0] == 0 #nie zostal juz zaden bialy pionek
		return 'Czarne wygraly!'
	if liczbaBialychICzarnychPionkow[1] == 0 #nie zostal juz zaden czarny pionek
		return 'Biale wygraly!'
	return ''
	
graczWykonujeRuch = (input) ->
	pozycjaStartowa = undefined
	pozycjaWynikowa = undefined
	plansza = planszaZapisana
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
	if !wybranePoleSpelniaZasadyGry(pozycjaStartowa, pozycjaWynikowa, plansza)
		return '[BŁĄD] Ruch niezgodny z zasadami!'
	plansza=zupdatujPlanszeNaPodstawiePozycjiStartowejIWynikowejOrazGracza(plansza, pozycjaStartowa, pozycjaWynikowa, "O")
	return planszaRysuj(plansza) + czyKtosWygral(plansza)

aiWykonujeRuch = () -> 
	plansza = planszaZapisana
	legitneRuchy = []
	AIszukaSwoichPionkow(plansza)
	ruch=AIdecydujeORuchu();
	#plansza=zupdatujPlanszeNaPodstawiePozycjiStartowejIWynikowejOrazGracza(plansza, [(legitneRuchy[ruch][0] + 1),(legitneRuchy[ruch][1] + 1)],[(legitneRuchy[ruch][2] + 1),(legitneRuchy[ruch][3] + 1)], "X")
	plansza=zupdatujPlanszeNaPodstawiePozycjiStartowejIWynikowejOrazGracza(plansza, [(ruch[0] + 1),(ruch[1] + 1)],[(ruch[2] + 1),(ruch[3] + 1)], "X")
	return planszaRysuj(plansza) + czyKtosWygral(plansza)

AIszukaSwoichPionkow = (plansza) ->
	i = 0
	while i < 8
		j = 0
		while j < 8
			if plansza[i][j].indexOf('X') == 0
				AIszukaDostepnychRuchowPionka(plansza, i, j)
			j++
		i++
	n = 0
	output = ""
	while n < legitneRuchy.length
		output += 'Mozliwe ruchy: ' + (legitneRuchy[n][0] + 1) + ',' + (legitneRuchy[n][1] + 1) + '->' + (legitneRuchy[n][2] + 1) + ',' + (legitneRuchy[n][3] + 1) + ' - priorytet ' +legitneRuchy[n][4]+'\n'
		n++
	console.log(output)

AIszukaDostepnychRuchowPionka = (plansza, i, j) ->
	pozycje = [
		[
			-1
			-1
		]
		[
			1
			-1
		]
		[
			-1
			1
		]
		[
			1
			1
		]
		[
			-2
			-2
		]
		[
			2
			-2
		]
		[
			-2
			2
		]
		[
			2
			2
		]
	]
	#console.log("-> BADAM PIONEK "+(i+1)+","+(j+1))
	x = 0
	while x < 8
		testowaPozycjaX=pozycje[x][0] + i
		testowaPozycjaY=pozycje[x][1] + j
		if pozycjePoprawne([testowaPozycjaX+1,testowaPozycjaY+1])
			#console.log('pozycja '+(testowaPozycjaX+1)+","+(testowaPozycjaY+1)+" jest poprawna")
			if poleJestPuste(plansza[testowaPozycjaX][testowaPozycjaY])
				#console.log('pozycja '+(testowaPozycjaX+1)+","+(testowaPozycjaY+1)+" jest pusta i to dobrze")
				#console.log("Badamy pionek "+[i+1,j+1]+" i czy moze wejsc na "+[testowaPozycjaX+1,testowaPozycjaY+1])
				if wybranePoleSpelniaZasadyGry([i+1,j+1],[testowaPozycjaX+1,testowaPozycjaY+1], plansza)
					#console.log('pozycja '+(testowaPozycjaX+1)+","+(testowaPozycjaY+1)+" spelnia zasady")
					ruch = [i, j, testowaPozycjaX, testowaPozycjaY]
					priorytet=ustalPriorytetRuchu(ruch, plansza)
					ruch.push priorytet
					legitneRuchy.push ruch
		x++
	legitneRuchy

ustalPriorytetRuchu = (ruch, plansza)	->
	#priorytet ruchow:
	#- zbicie damki
	#- zbicie pionka bliskiego zostania damką (2->1)
	#- zrobienie własnej damki (7->8)
	#- usunięcie przeciwnego pionka
	#- zwykly ruch
	if (Math.sqrt((ruch[0]-ruch[2])*(ruch[0]-ruch[2]))) == 1 #zwykly niezbijajacy ruch
		if (ruch[2] == 7) #jesli jest to pionek z szasa zostania damka
			return 8
		return 1
	if (Math.sqrt((ruch[0]-ruch[2])*(ruch[0]-ruch[2]))) == 2 #cos jest zbijane!
		pozycjaWrogiegoPionkaX = parseInt(ruch[2]) + parseInt((ruch[0] - (ruch[2])) / 2)
		pozycjaWrogiegoPionkaY = parseInt(ruch[3]) + parseInt((ruch[1] - (ruch[3])) / 2)
		if (plansza[pozycjaWrogiegoPionkaX][pozycjaWrogiegoPionkaY].indexOf('*') != -1) #tym zbijanym czyms jest damka
			return 15
		if (pozycjaWrogiegoPionkaX == 1) #jesli wrogi pionek jest o krok od ostania damka
			return 10
		return (8-pozycjaWrogiegoPionkaX) #priorytet zbijania zwyklych przeciwnych pionkow wzrasta wraz z ich bliskoscia zostania damka; max=6
	return 0
	
AIdecydujeORuchu = ->
	maxPriorytet = 0
	ruchyONajwyzszymPriorytecie = []
	ostatecznyWyborRuchu = 0
	i = 0
	while i < legitneRuchy.length
		if (legitneRuchy[i][4] >= maxPriorytet)
			console.log(legitneRuchy[i][4])
			console.log(maxPriorytet)
			maxPriorytet = legitneRuchy[i][4]
		i++
	j = 0
	while j < legitneRuchy.length
		if (legitneRuchy[j][4] == maxPriorytet)
			ruch = legitneRuchy[j]
			ruchyONajwyzszymPriorytecie.push ruch
		j++
	ostatecznyWyborRuchu = Math.floor(Math.random() * (ruchyONajwyzszymPriorytecie.length - 1))
	ruchyONajwyzszymPriorytecie[ostatecznyWyborRuchu]

zupdatujPlanszeNaPodstawiePozycjiStartowejIWynikowejOrazGracza = (plansza, pozycjaStartowa, pozycjaWynikowa, gracz) ->
	if przeciwnyPionekJestZbity(pozycjaStartowa, pozycjaWynikowa, plansza)
		pozycjaZbijanegoPionkaX = parseInt(pozycjaWynikowa[0]) + parseInt((pozycjaStartowa[0] - (pozycjaWynikowa[0])) / 2)
		pozycjaZbijanegoPionkaY = parseInt(pozycjaWynikowa[1]) + parseInt((pozycjaStartowa[1] - (pozycjaWynikowa[1])) / 2)
		plansza[pozycjaZbijanegoPionkaX-1][pozycjaZbijanegoPionkaY-1] = ''
	plansza[pozycjaWynikowa[0] - 1][pozycjaWynikowa[1] - 1] = plansza[pozycjaStartowa[0] - 1][pozycjaStartowa[1] - 1]
	plansza[pozycjaStartowa[0] - 1][pozycjaStartowa[1] - 1] = ''
	if plansza[pozycjaWynikowa[0] - 1][pozycjaWynikowa[1] - 1] == "O" 
		if pozycjaWynikowa[0]-1 == 0
			plansza[pozycjaWynikowa[0] - 1][pozycjaWynikowa[1] - 1] = "O*"
	if plansza[pozycjaWynikowa[0] - 1][pozycjaWynikowa[1] - 1] == "X" 
		if pozycjaWynikowa[0]-1 == 7
			plansza[pozycjaWynikowa[0] - 1][pozycjaWynikowa[1] - 1] = "X*"
	plansza
	
przeciwnyPionekJestZbity = (pozycjaStartowa, pozycjaWynikowa, plansza) ->
	pionek=plansza[pozycjaStartowa[0]-1][pozycjaStartowa[1]-1]
	potencjalnaPozycjaWrogiegoPionkaX = parseInt(pozycjaWynikowa[0]) + parseInt((pozycjaStartowa[0] - (pozycjaWynikowa[0])) / 2)
	potencjalnaPozycjaWrogiegoPionkaY = parseInt(pozycjaWynikowa[1]) + parseInt((pozycjaStartowa[1] - (pozycjaWynikowa[1])) / 2)
	if plansza[potencjalnaPozycjaWrogiegoPionkaX-1][potencjalnaPozycjaWrogiegoPionkaY-1].indexOf(wrogiPionek(pionek)) != -1
		return true
	return false
	
wybranePoleSpelniaZasadyGry = (pozycjaStartowa, pozycjaWynikowa, plansza) ->
	pionek=plansza[pozycjaStartowa[0]-1][pozycjaStartowa[1]-1]
	#jesli nie porusza sie po przekatnej
	if Math.abs(pozycjaStartowa[0] - (pozycjaWynikowa[0])) != Math.abs(pozycjaStartowa[1] - (pozycjaWynikowa[1]))
		return false
	#damka (moze bic we wszystkie kierunki)
	if pionek.indexOf('*') != -1
		if Math.abs(pozycjaStartowa[0] - (pozycjaWynikowa[0])) == 1
			return true
		if Math.abs(pozycjaStartowa[0] - (pozycjaWynikowa[0])) == 2
			if przeciwnyPionekJestZbity(pozycjaStartowa, pozycjaWynikowa, plansza)
				return true
			return false
	#zwykly pionek (moze bic tylko do przodu)
	if pionek != ''
		if pionek.indexOf('O') != -1
			if pozycjaStartowa[0] < pozycjaWynikowa[0]
				return false
		if pionek.indexOf('X') != -1
			if pozycjaStartowa[0] > pozycjaWynikowa[0]
				return false	
		if Math.abs(pozycjaStartowa[0] - (pozycjaWynikowa[0])) == 1
			return true
		if Math.abs(pozycjaStartowa[0] - (pozycjaWynikowa[0])) == 2
			if przeciwnyPionekJestZbity(pozycjaStartowa, pozycjaWynikowa, plansza)
				return true
			return false
	return true
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

#------------------------------------------------------------------------------------- 
 
wrogiPionek = (pionek) ->
	if pionek.indexOf('O') != -1
		return 'X'
	return 'O'
	
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