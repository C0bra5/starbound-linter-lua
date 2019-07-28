
let luaparse = require('./luaparse.js');

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
		return {
			name : 'starbound-linter-lua',
			grammarScopes: ['source.lua'],
			scope: 'file',
			lintsOnChange: true,
			lint : (textEditor) => {
				let messages = [];
				try{
					luaparse.parse(textEditor.buffer.getText(),{luaVersion: '5.3'})
				} catch(e){
					//fetch error range
					let buffer = textEditor.buffer;
					buffer.scanInRange(
						/([^\s]+)/,
						[buffer.positionForCharacterIndex(e.index),buffer.getEndPosition()],
						(matches)=>{
							e.range = matches.range;
							matches.stop();
						}
					)
					if (e.range == null) {
						e.range = [e.line, e.column];
					}
					messages.push(
						{
							location : {
								file : textEditor.getPath(),
								position : e.range
							},
							excerpt : e.message.substr(e.message.indexOf(']') + 1),
							type : 'error',
							severity : 'error'
						}
					)
				}
				return messages;
			}
		}
	}
};
