.POSIX:

CRYSTAL = crystal

test: test1 test2 test3 test4

test1:
	$(CRYSTAL) run test/*_test.cr -- --parallel 4

test2:
	$(CRYSTAL) run test/components/*_test.cr -- --parallel 4

test3:
	$(CRYSTAL) run test/component_parsers/*_test.cr -- --parallel 4

test4:
	$(CRYSTAL) run test/stream_parser/*_test.cr -- --parallel 4

.phony: test
