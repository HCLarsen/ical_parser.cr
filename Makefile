.POSIX:

CRYSTAL = crystal

test: .phony
	$(CRYSTAL) run test/*_test.cr -- --parallel 4

.phony:
