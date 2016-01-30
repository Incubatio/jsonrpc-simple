build: clean
	coffee --compile --output lib src

watch: clean
	coffee --compile --watch --output lib src

clean:
	rm -rf lib

deploy:
	git push -f origin HEAD:gh-pages

test:
	rm -rf test/build
	coffee --compile --output test/build test/src
	node test/build
.PHONY: test
