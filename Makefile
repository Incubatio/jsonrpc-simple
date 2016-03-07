build: clean
	coffee --compile --output lib src

watch: clean
	coffee --compile --watch --output lib src

clean:
	/bin/rm -rf lib

deploy:
	git push -f origin HEAD:gh-pages

test:
	/bin/rm -rf test/build
	coffee --compile --output test/build test/src
	node test/build
.PHONY: test
