hook.Add('Initialize','CH_S_9a86804b24b178a0008ce350e7e11da8', function()
	http.Post('http://coderhire.com/api/script-statistics/usage/19101/1052/9a86804b24b178a0008ce350e7e11da8', {
		port = GetConVarString('hostport'),
		hostname = GetHostName()
	})
end)