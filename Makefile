
TAG  := $(shell git describe --tags --match '[0-9]*\.[0-9]*')

all: ssh-ecs-run-task

venv:
	virtualenv venv || python3 -m venv venv
	. venv/bin/activate && pip install -U pip wheel && pip install -r requirements.txt
	touch venv

is-open-source-clean:
	@{ \
		if glide -q list 2>/dev/null | egrep -iq 'github.com/SocialCodeInc'; then \
			echo "ssh-ecs-run-task is OPEN SOURCE -- no dependencies on SocialCodeInc sources are allowed"; \
		else \
			echo "ssh-ecs-run-task is clean for OPEN SOURCE"; \
		fi; \
	}

is-clean-z-release:
	echo "TAG=$(TAG)"
	@{ \
		if [[ "$(TAG)" =~ .*\-[0-9]+\-g[0-9a-f]+$$ ]]; then \
		    last_tag=$$(git describe --tags --abbrev=0); \
	        echo "ERROR: there have been commits on this branch after the $$last_tag tag was created";  \
	        echo '       please create a fresh GIT Z tag `git tag -a X.Y.Z -m "description ..."`'; \
	        echo '       or build at an existing TAG instead of on a branch'; \
	        false; \
		elif ! [[ "$(TAG)" =~ ^[0-9]+(\.[0-9]+)+.* ]]; then \
	    	echo "$(TAG) is not a SEMVER Z tag"; \
	    	false; \
		fi; \
	}

ssh-ecs-run-task-whl: venv .mk.ssh-ecs-run-task-whl

.mk.ssh-ecs-run-task-whl: $(shell find . -type f | egrep -v '\.git/|\.mk\.|venv/' )
	rm -rf dist
	. venv/bin/activate && python setup.py bdist_wheel
	touch .mk.ssh-ecs-run-task-whl

install-venv: ssh-ecs-run-task-whl
	. venv/bin/activate &&  pip install --upgrade $(shell ls -t ./dist/*.whl | head -1)

install-local: ssh-ecs-run-task-whl
	pip install --upgrade $(shell ls -t ./dist/*.whl | head -1)

install-global: ssh-ecs-run-task-whl
	pip install --upgrade $(shell ls -t ./dist/*.whl | head -1)

test: is-open-source-clean ssh-ecs-run-task-whl
	echo DONE

publish: is-open-source-clean is-clean-z-release ssh-ecs-run-task-whl
	hub release create -a dist/*-$(TAG)*.whl -m'$(TAG)' $(TAG)

clean:
	rm -Rf venv
