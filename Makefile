build: clean
	coffee --compile --output build src

watch:
	coffee --compile --watch --output build src

clean: 
	rm -rf build

deploy: 
	git push -f origin HEAD:gh-pages

test:
	node tests/main.js
