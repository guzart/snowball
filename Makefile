start:
	elm-live src/Main.elm --output=public/app.js --dir=public --pushstate --open --debug

setup:
	npm i -g elm-live firebase-tools

.PHONY: all
