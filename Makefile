
all: ssh-ecs-run-task

venv:
	virtualenv venv
	. venv/bin/activate && pip install -U pip wheel && pip install -r requirements.txt
	touch venv

ssh-ecs-run-task: venv .mk.ssh-ecs-run-task

.mk.ssh-ecs-run-task: $(shell find . -type f | egrep -v '\.git/|\.mk\.|venv/' )
	. venv/bin/activate && python setup.py bdist_wheel
	touch .mk.ssh-ecs-run-task

install-venv: ssh-ecs-run-task
	. venv/bin/activate &&  pip install --upgrade $(shell ls -t ./dist/*.whl | head -1)

install-local: ssh-ecs-run-task
	pip install --upgrade $(shell ls -t ./dist/*.whl | head -1)

install-global: ssh-ecs-run-task
	pip install --upgrade $(shell ls -t ./dist/*.whl | head -1)

test: ssh-ecs-run-task
	echo DONE

