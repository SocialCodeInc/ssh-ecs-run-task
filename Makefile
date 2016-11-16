#
# Use a single tag across all these images and tools to keep it SIMPLE?
#
# TAG = $(git describe --tags)

all: sc-docker-tools

venv:
	virtualenv venv
	. venv/bin/activate && pip install -U pip wheel && pip install -r requirements.txt
	touch venv

#
# sc-docker tools.
#
sc-docker-tools: venv .mk.sc-docker-tools

.mk.sc-docker-tools: $(shell find . -type f | egrep -v '\.git/|\.mk\.|venv/' )
	. venv/bin/activate && python setup.py bdist_wheel
	touch .mk.sc-docker-tools

install-venv: sc-docker-tools
	. venv/bin/activate &&  pip install --upgrade $(shell ls -t ./dist/*.whl | head -1)

install-local: sc-docker-tools
	pip install --upgrade $(shell ls -t ./dist/*.whl | head -1)

install-global: sc-docker-tools
	pip install --upgrade $(shell ls -t ./dist/*.whl | head -1)

test: sc-docker-tools
	echo DONE

