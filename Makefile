all:

deploy:
	rsync -rvu --delete src/ /lipid/group/global\ mfiles/STORManalysis/
