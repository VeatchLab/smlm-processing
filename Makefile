all:

deploy:
	rsync -rvu src/ /lipid/group/global\ mfiles/STORManalysis/
	rsync -rvuls --delete src/ /lipid/group/global\ mfiles/STORManalysis/
