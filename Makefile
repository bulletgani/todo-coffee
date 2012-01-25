generate-js: deps
	@find src -name 'src/app.coffee' | xargs coffee -c -o .
	@find src -name 'src/apps/*.coffee' | xargs coffee -c -o public/js

deps:
	@test `which coffee` || echo 'You need to have CoffeeScript in your PATH.\nPlease install it using `brew install coffee-script` or `npm install coffee-script`.'

test: deps
	@find test -name '*_test.coffee' | xargs -n 1 -t coffee

publish: generate-js
	@test `which npm` || echo 'You need npm to do npm publish... makes sense?'
	npm publish
	@remove-js

link: generate-js
	@test `which npm` || echo 'You need npm to do npm link... makes sense?'
	npm link
	@remove-js

dev: generate-js
	@coffee -wc --bare -o src/app.coffee .
	@coffee -wc --bare -o src/apps/*.coffee public/js

.PHONY: all
