# Description:
#   Warcaby.
#
# Notes:
#   Warcaby.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md
#-----------------------------------------------------------

module.exports = (warcabot) ->
	
	warcabot.hear /warcaby/i, (res) ->
		res.send planszaRysuj(planszaNowa)
	warcabot.hear /test/i, (res) ->
		res.send '☺️'
#-------------------------------------------------------------------

planszaRysuj = (plansza) ->
  output = '\n     1| 2| 3| 4| 5| 6| 7| 8\n___________________________\n---------------------------'
  i = 0
  while i < 8
    output += '\n'
    output += i + 1 + ' ||'
    j = 0
    while j < 8
      pionek = plansza[i][j]
      if !pionek
        pionek = '  '
      output += pionek + '|'
      j++
    output += '\n---------------------------'
    i++
  output
		
planszaNowa = [["","BP","","BP","","BP","","BP"],
	["BP","","BP","","BP","","BP",""],
	["","BP","","BP","","BP","","BP"],
	["","","","","","","",""],
	["","","","","","","",""],
	["CP","","CP","","CP","","CP",""],
	["","CP","","CP","","CP","","CP"],
	["CP","","CP","","CP","","CP",""]]