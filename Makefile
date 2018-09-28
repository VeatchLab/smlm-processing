all:

deploy:
	rsync -rvvut src/ /lipid/group/global\ mfiles/STORManalysis/
	rsync -rvun --delete src/ /lipid/group/global\ mfiles/STORManalysis/

check:
	rsync -rvvutn --delete src/ /lipid/group/global\ mfiles/STORManalysis/

