
let luaparse = require('./luaparse.js')

const TOGGLE_CUSTOM_PATH_DEFAULT = false;
const CUSTOM_PATH_DEFAULT = '';

module.exports = {

	toggleCustomPath : TOGGLE_CUSTOM_PATH_DEFAULT,
	customPath : CUSTOM_PATH_DEFAULT,

	activate: function() {
		//make sure deps are in
		require('atom-package-deps').install('starbound-linter-lua')
		//return self
		return this;
	},

	deactivate: function() {
		//nothing to do as of now
	},

	provideLinter: function() {
		let grammarScopes = ['source.lua'];
		let scope = 'file';
		let lintOnFly = true;
		let lint = (textEditor) => {
			let messages = [];
			try{
				luaparse.parse(textEditor.buffer.getText())
			} catch(e){
				//fetch error range
				let buffer = textEditor.buffer;
				buffer.scanInRange(
					/[^\s]*/,
					[buffer.positionForCharacterIndex(e.index),buffer.getEndPosition()],
					(matches)=>{
						e.range = matches.range;
						matches.stop();
					}
				)
				messages.push(
					{
						filePath : textEditor.getPath(),
						range : e.range,
						text : e.message.substr(e.message.indexOf(']') + 1),
						type : 'error',
						severity : 'error'
					}
				)
			}
			return messages;
		}
		return {
			name : 'starbound-linter-lua',
			lint : lint,
			grammarScopes : grammarScopes,
			scope : scope,
			lintOnFly : lintOnFly
		};
	}
};
