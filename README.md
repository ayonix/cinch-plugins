To use with cinchize.
Example configuration:

	options:
		log_output: true
		dir_mode: normal
		dir: "/some/user/cinch/"
	servers:
  		hackint:
		server: irc.server.org
		port: 6667
		nick: TestBot
		channels:
		- "#testchannel"
		plugins:
		  -
			class: "Cinch::Plugins::Admin"
			options:
				file: "/some/user/cinch/db/admins.yml"
		  -
			class: "Cinch::Plugins::Frebi"
			options:
			  	player: mplayer
		  -
			class: "Cinch::Plugins::Mpd"
			options:
				address: localhost
				port: 6600
				password: ''
		  -
			class: "Cinch::Plugins::Title"
		  -
			class: "Cinch::Plugins::Youtube"
			options:
				player: mplayer
				address: localhost
				port: 6600
				password: ''
