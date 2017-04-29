var exec = require('cordova/exec');

function YoutubeVideoPlayer() {}

YoutubeVideoPlayer.prototype.openVideo = function(YTid) {
	exec(function(result) {
		console.log(result);
	},
	function(error) {
		console.log(error);
	},
	"YoutubeVideoPlayer",
	"openVideo",
	[YTid]
	);
}

YoutubeVideoPlayer.prototype.getVideo = function(YTid, success, error) {
	exec(function(result) {
		success(result);
	},
	function(error) {
		error(error);
	},
	"YoutubeVideoPlayer",
	"getVideo",
	[YTid]
	);
}

YoutubeVideoPlayer.prototype.setMetadata = function(args, success, error) {
	exec(function(result) {
		success(result);
	},
	function(error) {
		error(error);
	},
	"YoutubeVideoPlayer",
	"setMetadata",
	args
	);
}

var YoutubeVideoPlayer = new YoutubeVideoPlayer();
module.exports = YoutubeVideoPlayer