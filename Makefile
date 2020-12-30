F= files/docker/systemctl.py
B= 2016
FOR=today
DAY=%u
# 'make version FOR=yesterday' or 'make version DAY=0'

UBUNTU=ubuntu:18.04
PYTHON=python3
GIT=git
VERFILES = files/docker/systemctl.py files/docker/systemctl3.py testsuite.py

verfiles:
	@ grep -l __version__ */*.??* */*/*.??* | { while read f; do echo $$f; done; } 

version:
	@ grep -l __version__ $(VERFILES) | { while read f; do : \
	; Y=`date +%Y -d "$(FOR)"` ; X=$$(expr $$Y - $B) \
	; D=`date +%W$(DAY) -d "$(FOR)"` ; sed -i \
	-e "/^ *__version__/s/[.]-*[0123456789][0123456789][0123456789]*\"/.$$X$$D\"/" \
	-e "/^ *__version__/s/[.]\\([0123456789]\\)\"/.\\1.$$X$$D\"/" \
	-e "/^ *__copyright__/s/(C) [0123456789]*-[0123456789]*/(C) $B-$$Y/" \
	-e "/^ *__copyright__/s/(C) [0123456789]* /(C) $$Y /" \
	$$f; done; }
	@ grep ^__version__ $(VERFILES)
	@ $(GIT) add $(VERFILES) || true
	@ ver=`cat files/docker/systemctl3.py | sed -e '/__version__/!d' -e 's/.*= *"//' -e 's/".*//' -e q` \
	; echo "# $(GIT) commit -m v$$ver"

help:
	python files/docker/systemctl3.py help
2:
	cp -v files/docker/systemctl3.py files/docker/systemctl.py
	sed -i -e "s|/usr/bin/python3|/usr/bin/python2|" files/docker/systemctl.py
	sed -i -e "s|type hints are provide.*|generated from systemctl3.py - do not change|" files/docker/systemctl.py
	$(GIT) add files/docker/systemctl.py || true
	diff -U1 files/docker/systemctl3.py files/docker/systemctl.py || true

alltests: CH CP UA DJ

CH centos-httpd.dockerfile: ; ./testsuite.py test_6001
CP centos-postgres.dockerfile: ; ./testsuite.py test_6002
UA ubuntu-apache2.dockerfile: ; ./testsuite.py test_6005
DJ docker-jenkins: ; ./testsuite.py test_900*

COVERAGE=--coverage
est_%: ; rm .coverage*; rm -rf tmp/tmp.t$@ ; ./testsuite.py "t$@" -vv --coverage --keep
test_%: ; ./testsuite.py "$@" -vv
real_%: ; ./testsuite.py "$@" -vv
st_%: ; $(MAKE) 2 && ./testsuite.py "te$@" -vv $(WITH2)

keep/test_%: ; ./testsuite.py "$(notdir $@)" -vvv --keep

test: ; $(MAKE) type && $(MAKE) tests && $(MAKE) coverage

WITH2 = --python=/usr/bin/python2 --with=files/docker/systemctl.py
WITH3 = --python=/usr/bin/python3 --with=files/docker/systemctl3.py
todo/test_%:             ; ./testsuite.py   "$(notdir $@)" -vv --todo
15.2/test_%:             ; ./testsuite.py   "$(notdir $@)" -vv $(FORCE) --image=opensuse/leap:15.2
15.1/test_%:             ; ./testsuite.py   "$(notdir $@)" -vv $(FORCE) --image=opensuse/leap:15.1
15.0/test_%:             ; ./testsuite.py   "$(notdir $@)" -vv $(FORCE) --image=opensuse/leap:15.0
42.3/test_%:             ; ./testsuite.py   "$(notdir $@)" -vv $(FORCE) --image=opensuse:42.3
42.2/test_%:             ; ./testsuite.py   "$(notdir $@)" -vv $(FORCE) --image=opensuse:42.2
20.04/test_%:            ; ./testsuite.py   "$(notdir $@)" -vv $(FORCE) --image=ubuntu:20.04
18.04/test_%:            ; ./testsuite.py   "$(notdir $@)" -vv $(FORCE) --image=ubuntu:18.04
16.04/test_%:            ; ./testsuite.py   "$(notdir $@)" -vv $(FORCE) --image=ubuntu:16.04
8.3/test_%:              ; ./testsuite.py   "$(notdir $@)" -vv $(FORCE) --image=centos:8.3.2011
8.1/test_%:              ; ./testsuite.py   "$(notdir $@)" -vv $(FORCE) --image=centos:8.1.1911
8.0/test_%:              ; ./testsuite.py   "$(notdir $@)" -vv $(FORCE) --image=centos:8.0.1905
7.9/test_%:              ; ./testsuite.py   "$(notdir $@)" -vv $(FORCE) --image=centos:7.9.2009
7.7/test_%:              ; ./testsuite.py   "$(notdir $@)" -vv $(FORCE) --image=centos:7.7.1908
7.6/test_%:              ; ./testsuite.py   "$(notdir $@)" -vv $(FORCE) --image=centos:7.6.1810
7.5/test_%:              ; ./testsuite.py   "$(notdir $@)" -vv $(FORCE) --image=centos:7.5.1804
7.4/test_%:              ; ./testsuite.py   "$(notdir $@)" -vv $(FORCE) --image=centos:7.4.1708
7.3/test_%:              ; ./testsuite.py   "$(notdir $@)" -vv $(FORCE) --image=centos:7.3.1611
15.2/st_%:  ; $(MAKE) 2 && ./testsuite.py "te$(notdir $@)" -vv $(FORCE) --image=opensuse/leap:15.2 $(WITH2)
15.1/st_%:  ; $(MAKE) 2 && ./testsuite.py "te$(notdir $@)" -vv $(FORCE) --image=opensuse/leap:15.1 $(WITH2)
15.0/st_%:  ; $(MAKE) 2 && ./testsuite.py "te$(notdir $@)" -vv $(FORCE) --image=opensuse/leap:15.0 $(WITH2)
42.3/st_%:  ; $(MAKE) 2 && ./testsuite.py "te$(notdir $@)" -vv $(FORCE) --image=opensuse:42.3      $(WITH2)
42.2/st_%:  ; $(MAKE) 2 && ./testsuite.py "te$(notdir $@)" -vv $(FORCE) --image=opensuse:42.2      $(WITH2)
20.04/st_%: ; $(MAKE) 2 && ./testsuite.py "te$(notdir $@)" -vv $(FORCE) --image=ubuntu:20.04       $(WITH2)
18.04/st_%: ; $(MAKE) 2 && ./testsuite.py "te$(notdir $@)" -vv $(FORCE) --image=ubuntu:18.04       $(WITH2)
16.04/st_%: ; $(MAKE) 2 && ./testsuite.py "te$(notdir $@)" -vv $(FORCE) --image=ubuntu:16.04       $(WITH2)
8.3/st_%:   ; $(MAKE) 2 && ./testsuite.py "te$(notdir $@)" -vv $(FORCE) --image=centos:8.3.2011    $(WITH2)
8.1/st_%:   ; $(MAKE) 2 && ./testsuite.py "te$(notdir $@)" -vv $(FORCE) --image=centos:8.1.1911    $(WITH2)
8.0/st_%:   ; $(MAKE) 2 && ./testsuite.py "te$(notdir $@)" -vv $(FORCE) --image=centos:8.0.1905    $(WITH2)
7.9/st_%:   ; $(MAKE) 2 && ./testsuite.py "te$(notdir $@)" -vv $(FORCE) --image=centos:7.9.2009    $(WITH2)
7.7/st_%:   ; $(MAKE) 2 && ./testsuite.py "te$(notdir $@)" -vv $(FORCE) --image=centos:7.7.1908    $(WITH2)
7.6/st_%:   ; $(MAKE) 2 && ./testsuite.py "te$(notdir $@)" -vv $(FORCE) --image=centos:7.6.1810    $(WITH2)
7.5/st_%:   ; $(MAKE) 2 && ./testsuite.py "te$(notdir $@)" -vv $(FORCE) --image=centos:7.5.1804    $(WITH2)
7.4/st_%:   ; $(MAKE) 2 && ./testsuite.py "te$(notdir $@)" -vv $(FORCE) --image=centos:7.4.1708    $(WITH2)
7.3/st_%:   ; $(MAKE) 2 && ./testsuite.py "te$(notdir $@)" -vv $(FORCE) --image=centos:7.3.1611    $(WITH2)

basetests = test_[1234]
test2list = st_[567]
testslist = test_[567]
tests: ; $(MAKE) "${basetests}"
.PHONY: tests
15.3/tests:  ; $(MAKE) "15.3/$(testslist)"
15.2/tests:  ; $(MAKE) "15.2/$(testslist)"
15.1/tests:  ; $(MAKE) "15.1/$(testslist)"
15.0/tests:  ; $(MAKE) "15.0/$(testslist)"
42.3/tests:  ; $(MAKE) "42.3/$(testslist)"
42.2/tests:  ; $(MAKE) "42.2/$(testslist)"
20.04/tests: ; $(MAKE) "20.14/$(testslist)"
18.04/tests: ; $(MAKE) "18.04/$(testslist)"
16.04/tests: ; $(MAKE) "16.04/$(testslist)"
8.3/tests:   ; $(MAKE) "8.3/$(testslist)"
8.1/tests:   ; $(MAKE) "8.1/$(testslist)"
8.0/tests:   ; $(MAKE) "8.0/$(testslist)"
7.9/tests:   ; $(MAKE) "7.9/$(testslist)"
7.7/tests:   ; $(MAKE) "7.7/$(testslist)"
7.6/tests:   ; $(MAKE) "7.6/$(testslist)"
7.5/tests:   ; $(MAKE) "7.5/$(testslist)"
7.4/tests:   ; $(MAKE) "7.4/$(testslist)"
7.3/tests:   ; $(MAKE) "7.3/$(testslist)"
15.3/test2:  ; $(MAKE) "15.3/$(test2list)"
15.2/test2:  ; $(MAKE) "15.2/$(test2list)"
15.1/test2:  ; $(MAKE) "15.1/$(test2list)"
15.0/test2:  ; $(MAKE) "15.0/$(test2list)"
42.3/test2:  ; $(MAKE) "42.3/$(test2list)"
42.2/test2:  ; $(MAKE) "42.2/$(test2list)"
20.04/test2: ; $(MAKE) "20.04/$(test2list)"
18.04/test2: ; $(MAKE) "18.04/$(test2list)"
16.04/test2: ; $(MAKE) "16.04/$(test2list)"
8.3/test2:   ; $(MAKE) "8.3/$(test2list)"
8.1/test2:   ; $(MAKE) "8.1/$(test2list)"
8.0/test2:   ; $(MAKE) "8.0/$(test2list)"
7.9/test2:   ; $(MAKE) "7.9/$(test2list)"
7.7/test2:   ; $(MAKE) "7.7/$(test2list)"
7.6/test2:   ; $(MAKE) "7.6/$(test2list)"
7.5/test2:   ; $(MAKE) "7.5/$(test2list)"
7.4/test2:   ; $(MAKE) "7.4/$(test2list)"
7.3/test2:   ; $(MAKE) "7.3/$(test2list)"

nightrun: checkall
	$(MAKE) checks
checkall: checkall2020
checkall2020:
	$(MAKE) -j1 tests checkall2020.3 checkall2020.2
checkall2019:
	$(MAKE) -j1 tests checkall2019.3 checkall2019.2
checkall2019.3:
	$(MAKE) -j1 8.0/tests
	$(MAKE) -j1 18.04/tests 16.04/tests
	$(MAKE) -j1 15.1/tests 15.0/tests 42.3/tests
checkall2020.3:
	$(MAKE) -j1 8.3/tests
	$(MAKE) -j1 20.04/tests 18.04/tests
	$(MAKE) -j1 15.2/tests
checkall2019.2:
	$(MAKE) -j1 7.7/test2 7.5/test2 7.4/test2 7.3/test2
	$(MAKE) -j1 18.04/test2 16.04/test2
	$(MAKE) -j1 15.1/test2 15.0/test2 42.3/test2
checkall2020.2:
	$(MAKE) -j1 7.9/test2 7.7/test2
	$(MAKE) -j1 20.04/tests 18.04/test2
	$(MAKE) -j1 15.2/test2

check: check2018
	@ echo please run 'make checks' now
19 check2019: ; ./testsuite.py -vv --opensuse=15.1 --centos=7.7 --ubuntu=18.04
18 check2018: ; ./testsuite.py -vv --opensuse=15.0 --centos=7.5 --ubuntu=18.04
17 check2017: ; ./testsuite.py -vv --opensuse=42.3 --centos=7.4 --ubuntu=16.04
16 check2016: ; ./testsuite.py -vv --opensuse=42.2 --centos=7.3 --ubuntu=16.04

2/test_%:
	$(MAKE) tmp_systemctl_py_2
	./testsuite.py -vv $(notdir $@) --sometime=666 \
	  '--with=tmp/systemctl.py' --python=/usr/bin/python2
3/test_%:
	$(MAKE) tmp_systemctl_py_3
	./testsuite.py -vv $(notdir $@) --sometime=666 \
	  '--with=tmp/systemctl.py' --python=/usr/bin/python3

2/est_%:
	$(MAKE) tmp_systemctl_py_2
	./testsuite.py -vv t$(notdir $@) --sometime=666 --coverage \
	  '--with=tmp/systemctl.py' --python=/usr/bin/python2
3/est_%:
	$(MAKE) tmp_systemctl_py_3
	./testsuite.py -vv t$(notdir $@) --sometime=666 --coverage \
	  '--with=tmp/systemctl.py' --python=/usr/bin/python3

check2:
	$(MAKE) tmp_systemctl_py_2
	./testsuite.py -vv \
	  '--with=tmp/systemctl.py' --python=/usr/bin/python2
check3:
	$(MAKE) tmp_systemctl_py_3
	./testsuite.py -vv \
	  '--with=tmp/systemctl.py' --python=/usr/bin/python3

checks: checks.1 checks.2 checks.3 checks.4
checks.1:
	- rm .coverage* 
checks.2:
	$(MAKE) checks2_coverage
	for i in .coverage*; do mv $$i $$i.cov2; done
checks.3:
	$(MAKE) checks3_coverage
	for i in .coverage*; do mv $$i $$i.cov3; done
checks.4:
	coverage combine && coverage report && coverage annotate
	ls -l tmp/systemctl.py,cover
	@ echo ".... are you ready for 'make checkall' ?"

checks2:  
	rm .coverage* ; $(MAKE) checks2_coverage
checks2_coverage:
	$(MAKE) tmp_systemctl_py_2
	./testsuite.py -vv --coverage \
	   '--with=tmp/systemctl.py' --python=/usr/bin/python2
checks3: 
	rm .coverage* ; $(MAKE) checks3_coverage
	coverage3 combine && coverage3 report && coverage3 annotate
	ls -l tmp/systemctl.py,cover
checks3_coverage: 
	$(MAKE) tmp_systemctl_py_3
	./testsuite.py -vv --coverage \
	  '--with=tmp/systemctl.py' --python=/usr/bin/python3

2/test_%:
	$(MAKE) tmp_systemctl_py_2
	./testsuite.py -vv --coverage $(notdir $@) \
	   '--with=tmp/systemctl.py' --python=/usr/bin/python2

3/test_%: 
	$(MAKE) tmp_systemctl_py_3
	./testsuite.py -vv --coverage $(notdir $@) \
	  '--with=tmp/systemctl.py' --python=/usr/bin/python3

coverage: coverage3
	$(PYTHON) -m coverage combine && \
	$(PYTHON) -m coverage report && \
	$(PYTHON) -m coverage annotate
	- $(PYTHON) -m coverage xml -o tmp/coverage.xml
	- $(PYTHON) -m coverage html -o tmp/htmlcov
	ls -l tmp/systemctl.py,cover
coverage2: 
	$(MAKE) tmp_systemctl_py_2
	rm .coverage* ; ./testsuite.py -vv --coverage ${basetests} --xmlresults=TEST-systemctl-python2.xml \
	  '--with=tmp/systemctl.py' --python=/usr/bin/python2
coverage3:
	$(MAKE) tmp_systemctl_py_3
	rm .coverage* ; ./testsuite.py -vv --coverage ${basetests} --xmlresults=TEST-systemctl-python3.xml \
	  '--with=tmp/systemctl.py' --python=/usr/bin/python3

tmp_systemctl_py_2:
	@ test -d tmp || mkdir tmp
	@ cp files/docker/systemctl.py tmp/systemctl.py
tmp_systemctl_py_3:
	@ test -d tmp || mkdir tmp
	@ cp files/docker/systemctl3.py tmp/systemctl.py
tmp_ubuntu:
	if docker ps | grep $(UBU); then : ; else : \
	; docker run --name $(UBU) -d $(UBUNTU) sleep 3333 \
	; docker exec $(UBU) apt-get update -y --fix-missing \
	; docker exec $(UBU) apt-get install -y --fix-broken --ignore-missing python3-coverage mypy \
	; fi
	docker cp files $(UBU):/root/
	docker cp testsuite.py $(UBU):/root/ 
	docker cp reply.py $(UBU):/root/ 
UBU=test_ubuntu
ubu/test_%:
	$(MAKE) tmp_ubuntu
	docker exec $(UBU) python3 /root/testsuite.py -C /root -vv $(notdir $@)
ubu/st_%:
	$(MAKE) tmp_ubuntu
	docker exec $(UBU) python3 /root/testsuite.py -C /root -vv te$(notdir $@)

clean:
	- rm .coverage*
	- rm -rf tmp/tmp.test_*
	- rm -rf tmp/systemctl.py
	- rm -rf tmp.* types/tmp.*
	- rm -rf .mypy_cache files/docker/.mypy_cache

copy:
	cp -v ../docker-mirror-packages-repo/docker_mirror.py .
	cp -v ../docker-mirror-packages-repo/docker_mirror.pyi .

dockerfiles:
	for dockerfile in centos7-lamp-stack.dockerfile opensuse15-lamp-stack.dockerfile \
	; do test -f ../docker-systemctl-images/$$dockerfile || continue \
	; echo "###################################################################################################" > test-$$dockerfile \
	; echo "## this file is a copy from gdraheim/docker-systemctl-images where more real world examples are :)"  >> test-$$dockerfile \
	; echo "## https://github.com/gdraheim/docker-systemctl-images/blob/develop/$$dockerfile" >> test-$$dockerfile \
	; echo "###################################################################################################" >> test-$$dockerfile \
	; cat ../docker-systemctl-images/$$dockerfile >> test-$$dockerfile \
	; wc -l test-$$dockerfile \
	; done

syswants:
	./files/docker/systemctl3.py -c CacheDepsSysInit -c CacheDepsFile=tmp.deps.cache -c CacheSysinitFile=tmp.sysinit.cache daemon-reload -vvv

####### autoflakes
autoflakes: ; $${PKG:-zypper} install -y python3-autoflake
flake: flake.s.i
flake.s.i: ; autoflake files/docker/systemctl3.py

####### autopep8
autopep8: ; $${PKG:-zypper} install -y python3-autopep8
pep style: 
	$(MAKE) pep.s pep.t
pep.i style.i: 
	$(MAKE) pep.s.i pep.t.i
pep.s style.s     pep.s.diff style.s.diff:
	autopep8 files/docker/systemctl3.py --diff
pep.s.i style.s.i pep.s.apply style.s.apply:
	autopep8 files/docker/systemctl3.py --in-place
	git --no-pager diff files/docker/systemctl3.py
pep.t style.t     pep.t.diff style.t.diff:
	autopep8 testsuite.py --diff
pep.t.i style.t.i pep.t.apply style.t.apply:
	autopep8 testsuite.py --in-place
	git --no-pager diff testsuite.py

####### retype + stubgen
mypy:
	zypper install -y mypy
	zypper install -y python3-click python3-pathspec
	cd .. && git clone git@github.com:ambv/retype.git
	cd ../retype && git checkout 17.12.0
stub:
	stubgen -o tmp.types --include-private files/docker/systemctl3.py
stub.:
	stubgen -o tmp.types --include-private files/docker/systemctl3.py
	sed -i -e "/^basestring = str/d" -e "/xrange = range/d" tmp.types/systemctl3.pyi
	sed -i -e "/^EXEC_SPAWN/d" -e "/^_notify_socket_folder/d" tmp.types/systemctl3.pyi
	diff -U1 types/systemctl3.pyi tmp.types/systemctl3.pyi | head -20
type.:
	python3 ../retype/retype.py files/docker/systemctl3.py -t tmp.files/docker
	stubgen -o tmp.types --include-private tmp.files/docker/systemctl3.py
	sed -i -e "/^basestring = str/d" -e "/xrange = range/d" tmp.types/systemctl3.pyi
	sed -i -e "/^EXEC_SPAWN/d" -e "/^_notify_socket_folder/d" tmp.types/systemctl3.pyi
	diff -U1 types/systemctl3.pyi tmp.types/systemctl3.pyi | head -20
	mypy --strict tmp.files/docker/systemctl3.py 2>&1 | head -20
type:
	python3 ../retype/retype.py files/docker/systemctl3.py -t tmp.files/docker
	python3 format3.py -i tmp.files/docker/systemctl3.py
	@ grep -w format tmp.files/docker/systemctl3.py | grep -v internal | sed -e "s|^|ERROR: |"; true
	mypy --strict tmp.files/docker/systemctl3.py # --new-semantic-analyzer --show-traceback
type33:
	test -d tmp.types || mkdir tmp.types ; cp types/systemctl3.pyi tmp.types/systemctl33.pyi
	python3 ../retype/retype.py files/docker/systemctl33.py -t tmp.files/docker -p tmp.types
	python3 format3.py -i tmp.files/docker/systemctl33.py
	@ grep -w format tmp.files/docker/systemctl33.py | grep -v internal | sed -e "s|^|ERROR: |"; true
	mypy --strict tmp.files/docker/systemctl33.py # --new-semantic-analyzer --show-traceback
type.t type.testsuite:
	mypy --strict testsuite.py # --new-semantic-analyzer --show-traceback

####### box test
box:
	docker rm -f $@ ; docker run -d --name $@ --rm=true centos:centos7 sleep 600
	docker cp files/docker/systemctl.py box:/usr/bin/systemctl
	docker exec box systemctl daemon-reload -vvv
	@ echo : docker exec -it box bash
